local Project = {}
Project.__index = Project

function Project:match(bufnr)
  if self.config.match then
    return self.config:match(bufnr)
  end
  return false
end

function Project:attach(bufnr)
  if not self.initialized then
    self:on_init()
  end

  if self.config.on_attach then
    self.config:on_attach(bufnr)
  end

  self.attached_buffers[bufnr] = true
end

function Project:detach(bufnr)
  if self.config.on_detach then
    self.config:on_detach(bufnr)
  end
  self.attached_buffers[bufnr] = nil
end

function Project:on_init()
  if self.config.on_init then
    self.config:on_init()
  end
  self.initialized = true
end

function Project.new(config)
  local project_obj = {
    attached_buffers = {},
    workspace_folders = config.workspace_folders or {},
    initialized = false,
    config = config or {},
  }
  local self = setmetatable(project_obj, Project)
  return self
end

return Project
