require 'code_node/ir/node'

module CodeNode
  module IR

    class ModuleNode < Node
      def shape
        :box
      end
      def fillcolor
        if children["#{key}_ClassMethods"] && extended_by['ActiveSupport_Concern']
          '#000000'
        else
          '#666666'
        end
      end
      def fontcolor
        '#ffffff'
      end
      def mark_as_singleton
        @singleton = true
      end
    end
    
  end  
end
