require 'cog'

# Register code_node as a tool with cog
Cog::Config.instance.register_tool __FILE__ do |tool|

  # Define how new code_node generators are created
  #
  # Add context as required by your generator template.
  #
  # When the block is executed, +self+ will be an instance of Cog::Config::Tool::GeneratorStamper
  tool.stamp_generator do
    stamp 'code_node/generator.rb', generator_dest, :absolute_destination => true
  end
  
end
