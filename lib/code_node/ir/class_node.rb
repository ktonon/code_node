require 'code_node/ir/node'

module CodeNode
  module IR
    
    class ClassNode < Node
      def inherits_from=(super_node)
        @inherits_from = super_node
      end
      def shape
        :ellipse
      end
      def fillcolor
        '#cccccc'
      end
      def fontcolor
        '#000000'
      end
    end
    
  end  
end
