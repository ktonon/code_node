require 'cog'

module CodeNode
  module IR
    
    # A node in the {Graph}
    # Nodes come in two flavors: {#class?} and {#module?} nodes
    class Node

      include Cog::Generator
      
      # Node methods which are useful in templates
      module TemplateMethods
        
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
        
        # @return [Node,nil] the super class of this class. Will be +nil+ for modules.
        def super_class_node
          @inherits_from
        end
        
        # @return [Array<Node>] module nodes for which this node has an +include+ statement
        def inclusions
          @includes.values.sort
        end
      
        # @return [Array<Node>] module nodes for which this node has an +extend+ statement
        def extensions
          @extends.values.sort
        end
        
        # @return [String] fully qualified identifier for the node in the form <tt>Foo_Bar_Car</tt>. Ideal for graphviz identifiers.
        def key
          @path.join '_'
        end
        
        # @return [String] how the node will be labelled in the graph. Nodes without parents display their full {#path}, while nodes with parents only display their {#name}.
        def label
          @parent.nil? ? path : name
        end

        # Stamp the accumulated GraphViz styles in a format suitable for inclusion in a <tt>.dot</tt> file
        # @return [String] style in the form <tt>key1="value1" key2="value2"</tt>...
        def stamp_styles
          x = []
          style.each_pair do |key, value|
            x << "#{key}=\"#{value}\""
          end
          x.join ' '
        end
        
      end
      
      # {Node} methods which are useful for querying in matchers
      module QueryMethods

        # @return [Boolean] does this node represent a module?
        def module?
          @node_type == :module
        end

        # @return [Boolean] does this node represent a class?
        def class?
          @node_type == :class
        end
        
        # @return [String] fully qualified name of the node in the form <tt>'Foo::Bar::Car'</tt>. Not good as a graphviz identifier because of the colon (<tt>:</tt>) characters. Use {TemplateMethods#key} for graphviz identifiers instead.
        def path
          @path.join '::'
        end
        
        # @param path [String] a class or module path in the form <tt>Foo::Bar::Car</tt>
        # @return [Boolean] does this node include a {#module?} node with the given {#path}?
        def includes?(path)
          @includes.member? path
        end

        # @param path [String] a class or module path in the form <tt>Foo::Bar::Car</tt>
        # @return [Boolean] does this node extend a {#module?} node with the given {#path}?
        def extends?(path)
          @extends.member? path
        end

        # @param path [String] a class or module path in the form <tt>Foo::Bar::Car</tt>
        # @return [Boolean] does this node inherit from (directly or indirectly) a {#class?} node with the given {#path}? Note that a node inherits from itself according to this method. Recursively checks the ancestry of the node.
        def inherits_from?(path)
          # TODO: need process all nodes first, marking for deletion on the first pass, because the superclass gets deleting and then the inherits from relation breaks down
          self.path == path || @inherits_from && @inherits_from.inherits_from?(path)
        end
      
        # @return [Boolean] whether or not this node represents a singleton module. A singleton module is one which contains an <tt>extend self</tt> statement.
        def singleton?
          @singleton
        end

        # @return [Boolean] whether or not this node is an island. An island is a node with no connections to other nodes.
        def island?
          ([@parent, @inherits_from].all?(&:nil?) &&
           [@children, @inherited_by, @extends, @includes, @extended_by, @included_by].all?(&:empty?))
        end
        
      end
      
      # {Node} methods used during the graph building phase
      # @api developer
      module BuilderMethods
        
        attr_reader :style
        
        # Find a node contained in this node, or contained in this nodes {#parent}, recursively.
        # @return [Node, nil]
        def find(name)
          path = (@path + [name].flatten).join '::'
          @children[path] || (@parent && @parent.find(name))
        end
        
        # Add other as a child of this node
        # @param other [Node] another node
        # @return [nil]
        def contains(other)
          this = self
          @children[other.path] = other
          other.instance_eval {@parent = this}
          nil
        end
        
        # Add other as the super class of this node
        # @param other [Node] another node
        # @return [nil]
        def inherits_from(other)
          this = self
          @inherits_from = other
          other.instance_eval {@inherited_by[this.path] = this}
          nil
        end

        # Add other to this nodes includes set
        # @param other [Node] another node
        # @return [nil]
        def includes(other)
          this = self
          @includes[other.path] = other
          other.instance_eval {@included_by[this.path] = this}
          nil
        end
      
        # Add other to this nodes extends set
        # @param other [Node] another node
        # @return [nil]
        def extends(other)
          this = self
          @extends[other.path] = other
          other.instance_eval {@extended_by[this.path] = this}
          nil
        end
        
        # Mark this module node as a singleton
        # @return [nil]
        def mark_as_singleton
          throw :NodeNotAModule unless module?
          @singleton = true
        end
      
        # Remove any relations involving this node
        def prune
          this = self
          if @inherits_from
            @inherits_from.instance_eval {@inherited_by.delete this.path}
          end
          @inherited_by.each_value do |other|
            other.instance_eval {@inherits_from = nil}
          end
          if @parent
            @parent.instance_eval {@children.delete this.path}
          end
          @children.each_value do |other|
            other.instance_eval {@parent = nil}
          end
          @includes.each_value do |other|
            other.instance_eval {@included_by.delete this.path}
          end
          @included_by.each_value do |other|
            other.instance_eval {@includes.delete this.path}
          end
          @extends.each_value do |other|
            other.instance_eval {@extended_by.delete this.path}
          end
          @extended_by.each_value do |other|
            other.instance_eval {@extends.delete this.path}
          end
        end
      end
      
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
