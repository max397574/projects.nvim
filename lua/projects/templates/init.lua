local M = {}

function M:__index(k)
  local success, config = pcall(require, 'projects.templates.' .. k)
  if success then
    return config
  else
    vim.notify(string.format('[projects] No project template available for %s', k), vim.log.levels.WARN)
  end
end

return M
