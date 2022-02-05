local Project = require 'projects.project'

local function generate_project(server_configuration)
  local base_config = require(string.format('lspconfig.server_configurations.%s', server_configuration)).default_config
  return Project.new {
    priority = 10,
    match = function(self, bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
      if not vim.tbl_contains(base_config.filetypes, filetype) then
        return false
      end
      local detected_workspace = base_config.root_dir(bufname)
      if detected_workspace then
        self.workpace_folders = {
          {
            uri = vim.uri_from_fname(detected_workspace),
            name = detected_workspace,
          },
        }
        return true
      elseif base_config.single_file_support then
        self.workpace_folders = nil
        return true
      else
        return false
      end
    end,

    on_init = function(self)
      local config_copy = vim.deepcopy(base_config)

      -- Hack because of how lspconfig has been structured
      config_copy.root_dir = nil
      config_copy.workspace_folders = self.workspace_folders
      config_copy.on_init = function(client, initialization_results)
        if initialization_results.offsetEncoding then
          client.offset_encoding = initialization_results.offsetEncoding
        end
        client.notify('workspace/didChangeConfiguration', {
          settings = base_config.settings,
        })
      end

      self.client_id = vim.lsp.start_client(config_copy)
      self.client = vim.lsp.get_client_by_id(self.client_id)
    end,

    on_attach = function(self, bufnr)
      local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
      if vim.tbl_contains(base_config.filetypes, filetype) then
        vim.lsp.buf_attach_client(bufnr, self.client_id)
      end
    end,

    on_close = function(self, bufnr)
      vim.lsp.buf_detach_client(bufnr, self.client_id)
    end,

    on_termination = function(self)
      self.client.close()
    end,
  }
end

return generate_project
