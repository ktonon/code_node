module CodeNode
  
  class SexpWalker
    def initialize(graph, sexp)
      @graph = graph
      @root = sexp
    end
    def walk(purpose, s = nil)
      s ||= @root
      if [:module, :class].member?(s[0])
        @graph.node_for(s[0], s[1]) do |node|
          if purpose == :find_relations && s[0] == :class && !s[2].nil?
            super_node = @graph.node_for :class, s[2], :not_sure_if_nested => true
            unless super_node.nil?
              node.inherits_from = super_node
            end
          end
          rest = s[0] == :module ? s.slice(2..-1) : s.slice(3..-1)
          rest.each do |c|
            walk(purpose, c) if c.class == Sexp
          end
        end
      elsif purpose == :find_relations && s[0] == :call && s.length >= 4 && [:extend, :include].member?(s[2]) && !@graph.scope.empty?
        node = @graph.node_for :module, s[3], :not_sure_if_nested => true
        unless node.nil?
          if s[2] == :extend
            @graph.scope.last.extended_by[node.key] = node
          else
            @graph.scope.last.includes[node.key] = node
          end
        end
      else
        s.slice(1..-1).each do |c|
          walk(purpose, c) if c.class == Sexp
        end
      end
    end
  end
  
end
