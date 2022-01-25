Projects = {}

local M = {}

local project_watcher_enabled = false

M.match_projects = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  for _, project in pairs(Projects) do
    if project:match(bufname) then
      project:attach(bufnr)
    end
  end
end

M.list_projects = function()
  for _, project in pairs(Projects) do
    return project
  end
end

M.register = function(project)
  table.insert(Projects, project)
  if not project_watcher_enabled then
    vim.cmd [[ 
    augroup project_mangaer
      autocmd!
      unsilent autocmd BufEnter * lua require('projects.manager').match_projects()
    augroup end
    ]]
  end
end


return M
