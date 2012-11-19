require 'code_node/ir/node'

module CodeNode
  module IR

    class Graph

      # @api developer
      attr_reader :scope
      
      # @api developer
      def initialize
        @exclude_paths = []
        @exclude_patterns = []
        @exclude_procs = []
        @nodes = {}
        @scope = []
      end

      # @api developer
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
  
      def <<(node)
        @nodes[node.path] ||= node
        @nodes[node.path]
      end
      
      # Iterate through each {Node} with {Node#class?} in the graph
      # @yield [Node] a class node. Does not yield ignored nodes.
      # @return [nil]
      def each_class(&block)
        @nodes.values.select do |node|
          node.class? && !should_exclude?(node)
        end.sort.each &block
      end

      # Iterate through each {Node} with {Node#module?} in the graph
      # @yield [Node] a module node. Does not yield ignored nodes.
      # @return [nil]
      def each_module(&block)
        @nodes.values.select do |node|
          node.module? && !should_exclude?(node)
        end.sort.each &block
      end
      
      # Iterate through each containment relation in the graph
      def each_containment(&block)
        @nodes.values.sort.each do |node|
          if node.parent && !should_exclude?(node) && !should_exclude?(node.parent)
            block.call node.parent, node
          end
        end
      end

      # Iterate through each inheritance relation in the graph
      def each_inheritance(&block)
        @nodes.values.sort.each do |node|
          if node.super_class_node && !should_exclude?(node) && !should_exclude?(node.super_class_node)
            block.call node, node.super_class_node
          end
        end
      end

      # Iterate through each inclusion relation in the graph
      def each_inclusion(&block)
        @nodes.values.sort.each do |node|
          node.inclusions.each do |other|
            if !should_exclude?(node) && !should_exclude?(other)
              block.call node, other
            end
          end
        end
      end

      # Iterate through each extension relation in the graph
      def each_extension(&block)
        @nodes.values.sort.each do |node|
          node.extensions.each do |other|
            if !should_exclude?(node) && !should_exclude?(other)
              block.call node, other
            end
          end
        end
      end

      private
      
      def should_exclude?(node)
        @exclude_paths.any? {|path| path == node.path} ||
        @exclude_patterns.any? {|pattern| pattern =~ node.path} ||
        @exclude_procs.any? {|block| block.call(node)}
      end
    end
    
  end  
end
