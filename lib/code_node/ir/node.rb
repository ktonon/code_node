require 'cog'
require 'code_node/ir/node/builder_methods'
require 'code_node/ir/node/template_methods'
require 'code_node/ir/node/query_methods'

module CodeNode
  module IR
    
    # A node in the {Graph}
    # Nodes come in two flavors: {#class?} and {#module?} nodes
    class Node

      include Cog::Generator
      include BuilderMethods
      include TemplateMethods
      include QueryMethods
      
      # Initialize a node
      # @api developer
      # @param name [String, Array]
      # @option opt [Node] :parent (nil) if provided, the parent's path is prepended to name. The parent child is not made at this time though. See {BuilderMethods#contains} instead.
      # @option opt [Symbol] :node_type (:module) either <tt>:module</tt> or <tt>:class</tt>
      def initialize(name, opt={})
        @style = {}
        @node_type = opt[:node_type] || :module
        parent_path = opt[:parent] ? opt[:parent].instance_eval {@path} : []
        @path = if name.is_a? Array
          parent_path + name
        else
          parent_path + [name]
        end
        @name = @path.last
        @parent = nil
        @children = {}
        @inherits_from = nil
        @inherited_by = {}
        @includes = {}
        @included_by = {}
        @extends = {}
        @extended_by = {}
      end
      
      # @return [FixNum] order nodes by {#path}
      def <=>(other)
        path <=> other.path
      end

    end
  end
end
