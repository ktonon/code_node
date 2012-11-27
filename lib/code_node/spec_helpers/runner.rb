require 'open3'

module Cog
  module SpecHelpers
    
    class Runner
      def initialize(app)
        @cog = app
        @tools = []
      end
    end
    
    class Invocation
      
      # Redefine exec for testing code_node
      def exec(&block)
        ENV['COG_TOOLS'] = File.expand_path File.join(File.dirname(__FILE__), '..', 'cog_tool.rb')
        Open3.popen3 *@cmd do |i,o,e,t|
          block.call i,o,e
        end
      end
      
    end
  end
end
