module CodeNode
  module IR
    class Graph

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
        # @option opt [Boolean] :not_sure_if_nested (false)
        # @yieldparam node [Node]
        # @return [Node]
        def node_for(node_type, s, opt={}, &block)
          name = determine_name s
          return if name.nil?
    
          node = if opt[:not_sure_if_nested]
            search_for_node_in_parent(@scope.last, name) ||
            Node.new(name, :node_type => node_type)
          else
            Node.new name, :parent => @scope.last, :node_type => node_type
          end

          node = add_or_find_duplicate node
          unless block.nil?
            @scope << node
            block.call node
            @scope.pop
          end
          node
        end
      
        # Add the given node to the graph and return it. If a node with the same path is already in the graph, do not add it again, and return the original node.
        # @param node [Node] a node to add to the graph
        # @return [Node] the newly added node, or another node with the same path which was already in the graph
        def add_or_find_duplicate(node)
          @nodes[node.path] ||= node
          @nodes[node.path]
        end
      
        private
        
        # @param s [Sexp]
        # @return [Symbol, Array<Symbol>, nil]
        def determine_name(s)
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
        end
        
        # @param parent [Node, nil] the parent to search in
        # @param name [Array<Symbol>, Symbol] name of the node to search for
        # @return [Node, nil] the node, if found in the parent
        def search_for_node_in_parent(parent, name)
          if name.is_a?(Array)
            parts = name.dup
            n = parent && parent.find(parts.shift)
            while n && !parts.empty?
              n = n.find parts.shift
            end
            n
          else
            parent && parent.find(name)
          end
        end
        
      end
    end
  end
end
