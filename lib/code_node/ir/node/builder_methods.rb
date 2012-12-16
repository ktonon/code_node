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
          children[path] || (parent && parent.find(name))
        end
        
        # Add other as a child of this node
        # @param other [Node] another node
        # @return [nil]
        def contains(other)
          add_edge :children, other
        end
        
        # Add other as the super class of this node
        # @param other [Node] another node
        # @return [nil]
        def inherits_from(other)
          add_edge :inherits_from, other
        end

        # Add other to this nodes includes set
        # @param other [Node] another node
        # @return [nil]
        def includes(other)
          add_edge :includes, other
        end
      
        # Add other to this nodes extends set
        # @param other [Node] another node
        # @return [nil]
        def extends(other)
          add_edge :extends, other
        end
        
        # Add an edge between this node and another with the given relation type
        # @param rel [Symbol] the type of relation
        # @param other [Node] another node
        # @return [nil]
        def add_edge(rel, other)
          this = self
          inv = @inverse_relation[rel]
          @edge[rel][other.path] = other
          other.instance_eval do
            @edge[inv][this.path] = this
          end
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
          @edge.each_pair do |rel, edges|
            inv = @inverse_relation[rel]
            edges.each_value do |other|
              other.instance_eval do
                @edge[inv].delete this.path
              end
            end
          end
        end

      end
    end
  end
end
