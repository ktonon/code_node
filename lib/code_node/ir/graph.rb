require 'code_node/ir/node'
require 'code_node/ir/graph/builder_methods'
require 'code_node/ir/graph/template_methods'

module CodeNode
  module IR

    # A collection of {Node}s
    class Graph

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
