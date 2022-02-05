local M = {}

local active_projects = {}
local project_templates = {}

local templates_by_buf = {}

-- Want to move template project to active projects
-- Want to avoid remaking template project if the workspaceFolder of the template
-- Match should determine if *project* is started/attached
-- Should we also have separate logic for attaching a buffer to a project, and testing whether the buffer should trigger starting a project?
--
-- What makes a project template unique? The project id + project root
-- But projects can technically have multiple roots
--
--
-- project is already found
M.match_projects = function()
  local bufnr = vim.api.nvim_get_current_buf()

  local matching_projects = {}
  for _, project in pairs(active_projects) do
    if project:match(bufnr) then
      table.insert(matching_projects, project)
    end
  end

  for _, template in pairs(project_templates) do
    if template:match(bufnr) then
      table.insert(matching_projects, template)
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
