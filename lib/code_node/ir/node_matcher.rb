module CodeNode
  module IR
    
    # @api developer
    # Encapsulates a pattern match test for nodes
    class NodeMatcher
      
      def initialize(pattern)
        @pattern = pattern
      end
      
      # @param node [Node]
      # @return [Boolean] does the node match?
      def matches?(node)
        if @pattern.is_a? Proc
          @pattern.call node
        elsif @pattern.is_a? Regexp
          @pattern =~ node.path
        else
          @pattern.to_s == node.path
        end
      end

    end
  end
end
