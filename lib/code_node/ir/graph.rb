require 'code_node/ir/class_node'
require 'code_node/ir/module_node'

module CodeNode
  module IR

    class Graph

      attr_reader :scope

      def initialize
        @nodes = {}
        @scope = []
      end

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
            (node_type == :module ? ModuleNode : ClassNode).new(name)
          end
        else
          (node_type == :module ? ModuleNode : ClassNode).new(name, @scope.last)
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
        @nodes[node.key] ||= node
        @nodes[node.key]
      end
      def [](key)
        @nodes[key]
      end
      def nodes
        @nodes.values.sort
      end
    end
    
  end  
end
