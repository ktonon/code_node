module CodeNode
  module IR
    class Node
      
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
    end
  end
end