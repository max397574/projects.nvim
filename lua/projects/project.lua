local M = {}
M.__index = M

local project_id = 0

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
  project_id = project_id + 1
  return setmetatable(state, M)
end

return M
