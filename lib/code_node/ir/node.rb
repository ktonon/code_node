module CodeNode
  module IR
    
    class Node
      attr_reader :name, :parent, :children, :includes, :extended_by, :inherits_from
      def initialize(name, parent = nil)
        parent_path = parent ? parent.instance_eval {@path} : []
        @path = if name.is_a? Array
          parent_path + name
        else
          parent_path + [name]
        end
        @name = @path.last
        @parent = parent
        parent.children[key] = self unless parent.nil?
        @children = {}
        @includes = {}
        @extended_by = {}
      end
      def find(name)
        key = (@path + [name].flatten).join '_'
        @children[key] || (orphan? ? nil : @parent.find(name))
      end
      def key
        @path.join '_'
      end
      def path
        @path.join '::'
      end
      def label
        orphan? ? path : name
      end
      def to_s
        path
      end
      def <=>(other)
        path <=> other.path
      end
      def orphan?
        @parent.nil?
      end
      def derives_from?(k)
        key == k || @inherits_from && (@inherits_from.key == k || @inherits_from.derives_from?(k))
      end
      def should_render?
        !(orphan? && @children.empty? && @inherits_from.nil? && @extended_by.empty? && @includes.empty?) && key != 'ActiveSupport_Concern' && !derives_from?('ActiveRecord_ActiveRecordError') && name != :ClassMethods
      end
    end
  
  end
end
