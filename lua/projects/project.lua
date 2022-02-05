local M = {}
M.__index = M

local project_id = 0

local is_child = function(path, base)
  -- TODO: replace with pathlib
  local util = require('projects.util')
  path = util.path.sanitize(path)
  base = util.base.sanitize(base)
  return string.sub(path, 1, string.len(base)) == base
end

local default_should_attach = function(self, bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  if not vim.tbl_contains(self.config.filetypes, filetype) then
    return false
  end
  for workspace_folder, _ in ipairs(self.workspace_folders) do
    if is_child(bufname, workspace_folder) then
      return true
    end
  end
end

function M:should_attach(bufnr)
  return self.config:should_attach(bufnr)
end

function M:attach(bufnr)
  if self.attached_buffers[bufnr] then
    vim.notify(string.format('Project %s is already attached to buffer (id: %d)', self.name, bufnr))
  end
  if not self.initialized then
    self:initialize()
  end

  if self.config.on_attach then
    self.config:on_attach(bufnr)
  end

  self.attached_buffers[bufnr] = true
end

function M:detach(bufnr)
  if self.config.on_detach then
    self.config:on_detach(bufnr)
  end

  self.attached_buffers[bufnr] = nil
end

function M:initialize()
  if self.config.on_init then
    self.config:on_init()
  end
  self.initialized = true
end

function M.new(config)
  local state = {
    config = config or {},
    workspace_folders = config.workspace_folders or vim.NULL,
    attached_buffers = {},
    initialized = false,
    id = project_id,
    name = config.name or project_id
  }
  state.config.should_attach = state.config.should_attach or default_should_attach
  project_id = project_id + 1
  return setmetatable(state, M)
end

return M
