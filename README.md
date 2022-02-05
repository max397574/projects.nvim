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

A config table should consist of:

```lua
{ 
  on_attach = function(bufnr)
  on_init = function()
  on_detach = function()
  should_attach = function(bufnr)
  filetypes = [string]
  workspace_folders = [string]
}

```

The `match` function 

A project template is identical to a project 

