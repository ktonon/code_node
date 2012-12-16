module CodeNode
  module IR
    class Node
      
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
    end
  end
end