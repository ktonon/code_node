module CodeNode
  module DSL

    # Specify rules for generating the graph
    class GraphDefiner

      # @api developer
      # @param graph [IR::Graph] a graph for which rules can be defined
      def initialize(graph)
        @graph = graph
      end
      
      # Speficy an ignore rule for the graph.
      # Nodes matching the ignore rule will not be included in the graph.
      # Ignore rules can be given in one of three ways.
      #
      # * {String} provide a fully qualified path
      # * {Regexp} provide a pattern that will be tested against the {Node#path}
      # * {Proc} provide a block. If the block returns +true+ the node will be ignored
      #
      # @param name [String, Regexp, nil] fully qualified path or regular expression which will be compared to {Node#path}
      # @yield [Node] if provided, return +true+ to ignore the node
      # @return [nil]
      def ignore(name=nil, &block)
        if (name.nil? && block.nil?) || (name && block)
          raise ArgumentError.new('Provide either a name or a block') 
        end
        if block
          @graph.instance_eval {@exclude_procs << block}
        elsif name.is_a? Regexp
          @graph.instance_eval {@exclude_patterns << name}
        else
          @graph.instance_eval {@exclude_paths << name}
        end
        nil
      end
    end

  end
end
