$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../../../../lib'))
require 'code_node'

# Makes a graph of the project_source_path.
# Nodes in the graph are clases and modules from your project.
CodeNode.graph 'graph' do |g|

  # Nodes
  # =====

  # Ignore nodes with no relations to other nodes
  g.ignore &:island?

  # Uncomment and change the value to ignore a specific node
  g.ignore 'ActiveRecord::ConnectionAdapters::ConnectionManagement'
  g.ignore 'ActiveSupport::Autoload'
  g.ignore 'ActiveSupport::Concern'
  
  # Uncomment to ignore nodes named ClassMethods
  g.ignore /::ClassMethods$/

  # Uncomment and change the value to ignore all nodes descending
  # from a specific node
  g.ignore {|node| node.inherits_from? 'ActiveRecord::ActiveRecordError'}
  
  # Apply styles common to all classes
  g.style :shape => 'ellipse', :fillcolor => '#cccccc', :fontcolor => :black do |node|
    node.class?
  end

  # Apply styles common to all nodes
  g.style :shape => 'box', :fillcolor => '#333333', :fontcolor => :white do |node|
    node.module?
  end
  
  # Apply more specific style here
  # ...
  
  # Edges
  # =====
  #
  # There is currently no way to style edges from the DSL.
  # For now, there are only four categories of edges:
  #  - containment
  #  - inheritance
  #  - inclusion
  #  - extension
  #
  # They are style in the template. You can override the template
  # and change the color if you like.
  #   $ cog -t code_node template new -f code_node/graph.dot
end
