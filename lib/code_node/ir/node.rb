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
        @inverse_relation = {} # :rel => :inv_rel
        @edge = {} # :rel => { 'node::path' =>  }
        define_relation :parent, :children
        define_relation :inherits_from, :inherited_by
        define_relation :includes, :included_by
        define_relation :extends, :extended_by
      end
      
      # @param rel [Symbol] the name of a relation
      # @param inv [Symbol] the name of the inverse relation
      def define_relation(rel, inv)
        @inverse_relation[rel] = inv
        @inverse_relation[inv] = rel
        @edge[rel] = {}
        @edge[inv] = {}
      end
      
      # @return [FixNum] order nodes by {#path}
      def <=>(other)
        path <=> other.path
      end

    end
  end
end
