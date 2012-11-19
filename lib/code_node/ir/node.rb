require 'cog'

module CodeNode
  module IR
    
    # A node in the {Graph}
    # Nodes come in two flavors: {#class?} and {#module?} nodes
    class Node

      include Cog::Generator
      
      # @return [String] the name of the node. Not necessarilly unique.
      # @see {#path}
      attr_reader :name

      # @return [Node] node which contains this node
      # @example
      #   module Foo     # Foo is the parent
      #     module Bar   # to Bar
      #     end
      #   end
      attr_reader :parent

      # The child nodes of this node
      # @return [Hash<String,Node>] a mapping from node {#path} names to nodes
      # @example
      #   module Foo     # Foo has children
      #     module Bar   # Bar
      #     end          # and
      #     class Car    # Car
      #     end
      #   end
      attr_reader :children

      # @param name [String, Array]
      # @option opt [Node] :parent (nil)
      # @option opt [Symbol] :node_type (:module) either <tt>:module</tt> or <tt>:class</tt>
      def initialize(name, opt={})
        @node_type = opt[:node_type] || :module
        @parent = opt[:parent]
        parent_path = @parent ? @parent.instance_eval {@path} : []
        @path = if name.is_a? Array
          parent_path + name
        else
          parent_path + [name]
        end
        @name = @path.last
        @parent.children[path] = self unless @parent.nil?
        @children = {}
        @inherited_by = {}
        @includes = {}
        @included_by = {}
        @extends = {}
        @extended_by = {}
      end
      
      def find(name)
        path = (@path + [name].flatten).join '::'
        @children[path] || (@parent && @parent.find(name))
      end

      # @return [String] fully qualified identifier for the node in the form <tt>Foo_Bar_Car</tt>. Ideal for graphviz identifiers.
      def key
        @path.join '_'
      end

      # @return [String] fully qualified name of the node in the form <tt>'Foo::Bar::Car'</tt>. Not good as a graphviz identifier because of the colon (+:+) characters. Use {#key} for graphviz identifiers instead.
      def path
        @path.join '::'
      end

      # @return [String] how the node will be labelled in the graph. Nodes without parents display their full {#path}, while nodes with parents only display their {#name}.
      def label
        @parent.nil? ? path : name
      end

      # @return [FixNum] order nodes by {#path}
      def <=>(other)
        path <=> other.path
      end

      # @return [Boolean] whether or not this node represents a module
      def module?
        @node_type == :module
      end

      # @return [Boolean] whether or not this node represents a class
      def class?
        @node_type == :class
      end

      # @param other [Node]
      def inherits_from(other)
        this = self
        @inherits_from = other
        other.instance_eval {@inherited_by[this.path] = this}
      end

      # @return [Node,nil] the super class of this class. Will be +nil+ for modules.
      def super_class_node
        @inherits_from
      end

      # @param other [Node]
      def includes(other)
        this = self
        @includes[other.path] = other
        other.instance_eval {@included_by[this.path] = this}
      end
      
      # @return [Array<Node>] module nodes for which this node has an +include+ statement
      def inclusions
        @includes.values.sort
      end

      # @param other [Node]
      def extends(other)
        this = self
        @extends[other.path] = other
        other.instance_eval {@extended_by[this.path] = this}
      end

      # @return [Array<Node>] module nodes for which this node has an +extend+ statement
      def extensions
        @extends.values.sort
      end
      
      # Set the given class node as the super class of this node
      # @param super_node [Node] a {#class?} node
      # @return [nil]
      def inherits_from=(super_node)
        throw :NodeNotAClass unless class?
        throw :SuperNodeNotAClass unless super_node.class?
        @inherits_from = super_node
      end
      
      # @return [Boolean] whether or not this node inherits from a given node. Note that a node does inherit from itself, according to this method. Recursively checks the ancestry of the node.
      def inherits_from?(k)
        key == k || @inherits_from && (@inherits_from.key == k || @inherits_from.inherits_from?(k))
      end
            
      # Mark this module node as a singleton
      # @return [nil]
      def mark_as_singleton
        throw :NodeNotAModule unless module?
        @singleton = true
      end
      
      # @return [Boolean] whether or not this node represents a singleton module
      def singleton?
        @singleton
      end
      
      # @return [Boolean] whether or not this node is an island. An island is a node with no connections to other nodes.
      def island?
        ([@parent, @inherits_from].all?(&:nil?) &&
         [@children, @inherited_by, @extends, @includes, @extended_by, @included_by].all?(&:empty?))
      end

    end
  end
end
