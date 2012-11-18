# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','code_node/version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'code_node'
  s.version = Code_node::VERSION
  s.author = 'Kevin Tonon'
  s.email = 'kevin@betweenconcepts.com'
  s.homepage = 'betweenconcepts.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Create Class and Module graphs for Ruby projects'
  s.files = %w(LICENSE) + Dir.glob('cog/**/*') + Dir.glob('lib/**/*.rb')
  s.require_paths << 'lib'
  s.has_rdoc = 'yard'
  s.rdoc_options << '--title' << 'code_node' << '-ri'
  s.add_dependency('cog')
  s.add_dependency('ruby_parser')
  s.add_development_dependency('rake')
  s.add_development_dependency('yard')
end
