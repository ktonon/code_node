require 'code_node/ir/node'

module CodeNode
  module IR

    # A collection of {Node}s
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
      
      # {Graph} methods used during the graph building phase
      # @api developer
      module BuilderMethods

        attr_reader :scope
      
        def apply_styles
          @nodes.each_value do |node|
            @style_matchers.each do |pair|
              if pair[0].matches? node
                node.style.update pair[1]
              end
            end
          end
        end
        
        # @return [FixNum] were any more nodes pruned?
        def prune
          prunees = []
          @nodes.each_value do |node|
            if @exclude_matchers.any? {|m| m.matches? node}
              prunees << node
            end
          end
          prunees.each do |node|
            puts "  #{node.path}"
            node.prune
            @nodes.delete node.path
          end
          prunees.length
        end
        
        # Find a node or create it and add it to the graph
        # @api developer
        # @param node_type [Symbol] either <tt>:module</tt> or <tt>:class</tt>
        # @param s [Symbol, Sexp] either flat name, or a Sexp representing a color (<tt>:</tt>) separated path.
        # @yieldparam node [Node]
        # @return [Node]
        def node_for(node_type, s, opt={}, &block)
          name = if s.is_a? Symbol
            s
          elsif s[0] == :const
            s[1]
          elsif s[0] == :colon2
            x = []
            while s[0] == :colon2
              x << s[2] ; s = s[1]
            end
            x << s[1]
            x.reverse
          elsif s[0] == :self
            @scope.last.mark_as_singleton
            nil
          end
          return if name.nil?
    
          node = if opt[:not_sure_if_nested]
            if @scope.length > 1 && @scope[-2].find(name)
              @scope[-2].find name
            else
              Node.new name, :node_type => node_type
            end
          else
            Node.new name, :parent => @scope.last, :node_type => node_type
          end

          node = self << node
          unless block.nil? || node.nil?
            @scope << node
            block.call node
            @scope.pop
          end
          node
        end
      
        # Add the given node to the graph and return it. If a node with the same path is already in the graph, do not add it again, and return the original node.
        # @param node [Node] a node to add to the graph
        # @return [Node] the newly added node, or another node with the same path which was already in the graph
        def <<(node)
          @nodes[node.path] ||= node
          @nodes[node.path]
        end
      
      end
      
      include BuilderMethods
      include TemplateMethods
      
      # @api developer
      def initialize
        @exclude_matchers = []
        @style_matchers = []
        @nodes = {}
        @scope = []
      end

    end
  end  
end
