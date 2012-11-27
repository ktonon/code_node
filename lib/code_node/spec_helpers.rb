require 'cog/spec_helpers'
require 'code_node/spec_helpers/runner'
require 'code_node/spec_helpers/dot_file'

module CodeNode
  
  # RSpec helpers specific to code_node
  module SpecHelpers
  end
  
end

module Cog
  
  # Customizations to cog RSpec helpers for use with code_node
  module SpecHelpers
    
    def spec_root
      File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'spec')
    end
    
  end
end
