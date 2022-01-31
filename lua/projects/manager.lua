local M = {}

local active_projects = {}
local project_templates = {}

-- Want to move template project to active projects
-- Want to avoid remaking template project if the workspaceFolder of the template
-- project is already found
M.match_projects = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  local matching_projects = {}
  for _, project in pairs(active_projects) do
    if project:match(bufname) then
      table.insert(matching_projects, project)
    end
  end

  for _, project in pairs(project_templates) do
    if project:match(bufname) then
      table.insert(matching_projects)
    end
  end

  table.sort(matching_projects, function(a, b)
    return a.priority > b.priority
  end)

  for _, project in pairs(matching_projects) do
    project:attach(bufnr)
    if project.exclusive then
      break
    end
  end
end

local project_watcher_enabled = false

M.register = function(project)
  table.insert(project_templates, project)
  if not project_watcher_enabled then
    vim.cmd [[ 
    augroup project_mangaer
      autocmd!
      unsilent autocmd BufEnter * lua require('projects.manager').match_projects()
    augroup end
    ]]
  end
end

M.list_projects = function()
  return vim.deepcopy(active_projects)
end

return M
