require 'cog'
include Cog::Generator

# Register code_node as a tool with cog
Cog.register_tool __FILE__ do |tool|

  # Define how new code_node generators are created
  tool.stamp_generator do |name, dest|
    @name = name
    stamp 'code_node/generator.rb', dest, :absolute_destination => true
  end
  
end
