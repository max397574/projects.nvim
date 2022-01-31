local M = {}
M.__index = M

function M:match(bufnr)
  return self.config:match(bufnr)
end

function M:attach(bufnr)
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
  }
  return setmetatable(state, M)
end

return M
