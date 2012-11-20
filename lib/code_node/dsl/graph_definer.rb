require 'code_node/ir/node_matcher'

module CodeNode
  module DSL

    # Specify rules for generating the graph
    class GraphDefiner

      # @api developer
      # @param graph [IR::Graph] a graph for which rules can be defined
      def initialize(graph)
        @graph = graph
      end
      
      # Specify an ignore rule for the graph.
      # Nodes matching the ignore rule will not be included in the graph. Ignore rules can be given in one of three ways,
      #
      # * +String+ provide a fully qualified path which will have to match {IR::Node::QueryMethods#path} exactly
      # * +Regexp+ provide a pattern that will be tested against the {IR::Node::QueryMethods#path}
      # * +Proc+ provide a block. If the block returns +true+ the node will be ignored
      #
      # @example
      #   CodeNode.graph 'my_graph' do |g|
      #
      #     # Using a full path
      #     g.ignore 'Foo::Bar::Car'
      #
      #     # Using a regular expression
      #     g.ignore /ClassMethods$/
      #
      #     # Using a block
      #     g.ignore do |node|
      #       node.inherits_from? 'Exception'
      #     end
      #   end
      #
      # @param name [String, Regexp, nil] fully qualified path or regular expression which will be compared to {IR::Node::QueryMethods#path}
      # @yieldparam node [IR::Node::QueryMethods] if provided, return +true+ to ignore the node
      # @return [nil]
      def ignore(name=nil, &block)
        if (name.nil? && block.nil?) || (name && block)
          raise ArgumentError.new('Provide either a name or a block') 
        end
        matcher = IR::NodeMatcher.new name || block
        @graph.instance_eval {@exclude_matchers << matcher}
        nil
      end
      
      # Specify a rule for styling nodes.
      # Nodes matching the given rule will have the provided style attributes applied. Rules can be given in one of three ways,
      #
      # * +String+ provide a fully qualified path which will have to match {IR::Node::QueryMethods#path} exactly
      # * +Regexp+ provide a pattern that will be tested against the {IR::Node::QueryMethods#path}
      # * +Proc+ provide a block
      #
      # @example
      #   CodeNode.graph 'my_graph' do |g|
      #
      #     # Using a full path
      #     g.style 'Foo::Bar::Car', :shape => 'box'
      #
      #     # Using a regular expression
      #     g.style /ClassMethods$/, :fillcolor => '#336699'
      #
      #     # Using a block
      #     g.style :penwidth => 3 do |node|
      #       node.extends? 'ActiveSupport::Concern'
      #     end
      #   end
      #
      # @param name [String, Regexp, nil] fully qualified path or regular expression which will be compared to {IR::Node::QueryMethods#path}
      # @param style [Hash] a set of attributes and values to apply to matching nodes. For a full list of applicable to GraphViz nodes: http://www.graphviz.org/content/attrs
      # @yieldparam node [IR::Node::QueryMethods] if provided, return +true+ to indicate a match
      # @return [nil]
      def style(name=nil, style={}, &block)
        style, name = name, nil if name.is_a?(Hash)
        if (name.nil? && block.nil?) || (name && block)
          raise ArgumentError.new('Provide either a name or a block') 
        end
        matcher = IR::NodeMatcher.new name || block
        @graph.instance_eval {@style_matchers << [matcher, style]}
        nil
      end
    end

  end
end
