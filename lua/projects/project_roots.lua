local util = require 'projects.util'
local function find_project_root(identifier)
  local project_patterns = {
    ada = util.root_pattern('*.gpr', '*.adc'),
    angular = util.root_pattern 'angular.json',
    ansible = util.root_pattern('ansible.cfg', '.ansible-lint'),
    arduino = util.root_pattern '*.ino',

    -- C family
    c = util.root_pattern('compile_commands.json', 'compile_flags.txt', '.clangd', '.ccls'),
    cpp = util.root_pattern('compile_commands.json', 'compile_flags.txt', '.clangd', '.ccls'),
    objc = util.root_pattern('compile_commands.json', 'compile_flags.txt', '.clangd', '.ccls'),
    objcpp = util.root_pattern('compile_commands.json', 'compile_flags.txt', '.clangd', '.ccls'),
    --

    -- clojure
    clojure = util.root_pattern('project.clj', 'deps.edn', 'build.boot', 'shadow-cljs.edn'),
    edn = util.root_pattern('project.clj', 'deps.edn', 'build.boot', 'shadow-cljs.edn'),
    --

    cmake = util.root_pattern('compile_commands.json', 'build'),
    ql = util.root_pattern 'qlpack.yml',
    crystal = util.root_pattern 'shard.yml',
    cs = util.root_pattern('*.sln', '*.csproj'),

    -- css
    css = util.root_pattern 'package.json',
    scss = util.root_pattern 'package.json',
    less = util.root_pattern 'package.json',
  }

  return project_patterns(identifier)
end

return find_project_root
