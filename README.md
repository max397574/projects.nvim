# Description

This repo is not for public use. It is for experimentation on a projects module.

# Installation

```lua
local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'mjlbach/projects.nvim'
end)
```

# Example project
```lua
local Project = require 'projects.project'

function string.starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

local c_project = Project.new {
  priority = 10,
  workspace_folders = {
    {
      uri = vim.uri_from_fname '/home/michael/Repositories/neovim/neovim',
      name = '/home/michael/Repositories/neovim/neovim',
    },
  },
  -- resolve_project = function()
  -- end,
  match = function(self, bufname)
    if string.starts(bufname, '/Users/michael/Repositories/neovim') then
      return true
    else
      return false
    end
  end,

  on_init = function(self)
    local clangd_configuration = require('lspconfig.server_configurations.clangd').default_config
    local lua_configuration = require('lspconfig.server_configurations.sumneko_lua').default_config
    clangd_configuration.workspace_folders = self.workspace_folders
    lua_configuration.workspace_folders = self.workspace_folders

    self.clangd_id = vim.lsp.start_client(clangd_configuration)
    self.lua_id = vim.lsp.start_client(lua_configuration)
    self.clangd_client = vim.lsp.get_client_by_id(self.clangd_id)
    self.lua_client = vim.lsp.get_client_by_id(self.lua_id)
  end,

  on_attach = function(self, bufnr)
    if vim.api.nvim_buf_get_option(0, 'filetype') == 'lua' then
      vim.lsp.buf_attach_client(bufnr, self.lua_id)
    elseif vim.api.nvim_buf_get_option(0, 'filetype') == 'c' then
      vim.lsp.buf_attach_client(bufnr, self.clangd_id)
    end
  end,

  on_close = function(self, bufnr)
    vim.lsp.buf_detach_client(bufnr, self.clangd_id)
    vim.lsp.buf_detach_client(bufnr, self.lua_id)
  end,

  on_termination = function(self)
    self.clangd_client.close()
    self.lua_client.close()
  end,
}

require('projects.manager').register(c_project)

local pyright_project = require('projects.lspconfig_wrapper')('pyright')
require('projects.manager').register(pyright_project)

```


### Project vs. project config file vs. project template

A project can be directly instantiated by calling:

```lua
local Project = require 'projects.project'
Project.new({})
```

`Project.new()` takes a config table and returns a `Project` object.

A config table can consist of the following optional entries:

```lua
{ 
  should_attach = function(bufnr),
  workspace_folders = [string]
  filetypes = [string]
  priority = number
  exclusive = boolean

  on_init = function()
  on_attach = function(bufnr)
  on_detach = function()
}

```

`should_attach` is a callback function that takes in the current buffer id and returns a boolean whether the current buffer should attach to the project. *This is the only config item for which there is a default value. The default config checks if:
* The current buffer name is a child of one of the workspace folders. If empty, the Project will not attach to any buffer.
* The current buffer filetype matches those of `filetypes`. If empty, the Project will attach to any buffer filetype.

`workspace_folders` is a table of strings that specify the folders that constitute the project. All files that exist under these folders are assumed to belong to the project. This table is most commonly used by `should_attach` to determine if the current buffer should be attached to the project. `workspace_folders` should *only* use absolute paths, as these are not expanded.

`filetypes` is a table of strings specifying the vim filetypes to which this project should attach. It is principally used by the default `should_attach` to allow restricting the project to a subset of filetypes.

`priority` is a number specifying the priority of the project. A higher number indicates a higher priority. This is most often used in conjunction with the `exclusive` key to allow setting a priority order in which projects should be attached to the buffer. That is, by setting the priority for a project to a high number and `exclusive` to true, a user can ensure that no other project attempts to attach to this buffer.

`exclusive` is a boolean specifying whether additional projects should attempt to attach to this buffer.

`on_init` is a callback function that is called after the project is initialized. A project is initialized before the first `on_attach` callback is invoked. `on_init` is typically used to launch language servers or set project level variables.

`on_attach` is a callback function that takes in the buffer number and is run the first time this buffer is opened given that it matches the project. If the project has no `attached_buffers` then the project is first initialized (which calls `on_init`). `on_attach` is typically used to add keybindings and set buffer-local settings.

`on_detach` is a callback function that takes in the buffer number and is executed when this buffer is detached from the projects. `on_detach` is typically used to clear buffer-local settings and keybindings.


