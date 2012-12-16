module CodeNode
  module IR
    class Node

      # {Node} methods used during the graph building phase
      # @api developer
      module BuilderMethods
        
        attr_reader :style
        
        # Find a node contained in this node, or contained in this nodes {#parent}, recursively.
        # @return [Node, nil]
        def find(name)
          path = (@path + [name].flatten).join '::'
          @children[path] || (@parent && @parent.find(name))
        end
        
        # Add other as a child of this node
        # @param other [Node] another node
        # @return [nil]
        def contains(other)
          this = self
          @children[other.path] = other
          other.instance_eval {@parent = this}
          nil
        end
        
        # Add other as the super class of this node
        # @param other [Node] another node
        # @return [nil]
        def inherits_from(other)
          this = self
          @inherits_from = other
          other.instance_eval {@inherited_by[this.path] = this}
          nil
        end

        # Add other to this nodes includes set
        # @param other [Node] another node
        # @return [nil]
        def includes(other)
          this = self
          @includes[other.path] = other
          other.instance_eval {@included_by[this.path] = this}
          nil
        end
      
        # Add other to this nodes extends set
        # @param other [Node] another node
        # @return [nil]
        def extends(other)
          this = self
          @extends[other.path] = other
          other.instance_eval {@extended_by[this.path] = this}
          nil
        end
        
        # Mark this module node as a singleton
        # @return [nil]
        def mark_as_singleton
          throw :NodeNotAModule unless module?
          @singleton = true
        end
      
        # Remove any relations involving this node
        def prune
          this = self
          if @inherits_from
            @inherits_from.instance_eval {@inherited_by.delete this.path}
          end
          @inherited_by.each_value do |other|
            other.instance_eval {@inherits_from = nil}
          end
          if @parent
            @parent.instance_eval {@children.delete this.path}
          end
          @children.each_value do |other|
            other.instance_eval {@parent = nil}
          end
          @includes.each_value do |other|
            other.instance_eval {@included_by.delete this.path}
          end
          @included_by.each_value do |other|
            other.instance_eval {@includes.delete this.path}
          end
          @extends.each_value do |other|
            other.instance_eval {@extended_by.delete this.path}
          end
          @extended_by.each_value do |other|
            other.instance_eval {@extends.delete this.path}
          end
        end
        
      end
    end
  end
end
