require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb", "README.markdown"]
  t.options = [
    '--query', '@api.text != "unstable" && @api.text != "developer"']
end

spec = eval(File.read('code_node.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end
