module CodeNode
  module IR
    class Graph
      
      # {Graph} methods which are useful in templates
      module TemplateMethods
        
        # Iterate through each {Node} with {Node::QueryMethods#class?} in the graph
        # @yieldparam node [Node::TemplateMethods] a class node. Does not yield ignored nodes.
        # @return [nil]
        def each_class(&block)
          @nodes.values.select do |node|
            node.class?
          end.sort.each &block
        end

        # Iterate through each {Node} with {Node::QueryMethods#module?} in the graph
        # @yieldparam node [Node::TemplateMethods] a module node. Does not yield ignored nodes.
        # @return [nil]
        def each_module(&block)
          @nodes.values.select do |node|
            node.module?
          end.sort.each &block
        end
      
        # Iterate through each containment relation in the graph
        # @example
        #   # a -> b (A contains B)
        #   module A
        #     module B
        #     end
        #   end
        # @yieldparam a [Node::TemplateMethods] the container node
        # @yieldparam b [Node::TemplateMethods] the contained node
        # @return [nil]
        def each_containment(&block)
          @nodes.values.sort.each do |node|
            if node.parent
              block.call node.parent, node
            end
          end
        end

        # Iterate through each inheritance relation in the graph
        # @example
        #   # a -> b (A inherits from B)
        #   class A < B
        #   end
        # @yieldparam a [Node::TemplateMethods] the derived class node
        # @yieldparam b [Node::TemplateMethods] the super class node
        # @return [nil]
        def each_inheritance(&block)
          @nodes.values.sort.each do |node|
            if node.super_class_node
              block.call node, node.super_class_node
            end
          end
        end

        # Iterate through each inclusion relation in the graph
        # @example
        #   # a -> b (A includes B)
        #   module A
        #     include B
        #   end
        # @yieldparam a [Node::TemplateMethods] the which includes
        # @yieldparam b [Node::TemplateMethods] the included node
        # @return [nil]
        def each_inclusion(&block)
          @nodes.values.sort.each do |node|
            node.inclusions.each do |other|
              block.call node, other
            end
          end
        end

        # Iterate through each extension relation in the graph
        # @example
        #   # a -> b (A extends B)
        #   module A
        #     extend B
        #   end
        # @yieldparam a [Node::TemplateMethods] the which extends
        # @yieldparam b [Node::TemplateMethods] the extended node
        # @return [nil]
        def each_extension(&block)
          @nodes.values.sort.each do |node|
            node.extensions.each do |other|
              block.call node, other
            end
          end
        end
        
      end
    end
  end
end
