module CodeNode
  
  # @api developer
  # Walks a Sexp representing a ruby file looking for classes and modules.
  class SexpWalker
    
    # Initialize a walker with a graph and sexp
    #
    # All files in a code base should be walked once in <tt>:find_nodes</tt> mode, and then walked again in <tt>:find_relations</tt> mode.
    #
    # @param graph [IR::Graph] a graph to which nodes and relations will be added
    # @param sexp [Sexp] the root sexp of a ruby file
    # @option opt [Symbol] :mode (:find_nodes) one of <tt>:find_nodes</tt> or <tt>:find_relations</tt>
    def initialize(graph, sexp, opt={})
      @graph = graph
      @root = sexp
      @mode = opt[:mode] || :find_nodes
    end
    
    # Walk the tree rooted at the given sexp
    # @param s [Sexp] if +nil+ will be the root sexp
    # @return [nil]
    def walk(s = nil)
      s ||= @root
      if [:module, :class].member?(s[0])
        add_node s
      elsif find_relations? && s[0] == :call && s.length >= 4 && [:extend, :include].member?(s[2]) && !@graph.scope.empty?
        add_relation s
      else
        walk_siblings s.slice(1..-1)
      end
    end
    
    private
    
    def walk_siblings(s)
      s.each do |c|
        walk(c) if c.class == Sexp
      end
    end
    
    def add_node(s)
      node = @graph.node_for(s[0], s[1]) do |node|
        if find_relations? && s[0] == :class && !s[2].nil?
          super_node = @graph.node_for :class, s[2], :not_sure_if_nested => true
          node.inherits_from super_node unless super_node.nil?
        end
        walk_siblings s.slice((s[0] == :module ? 2 : 3)..-1)
      end
      unless @graph.scope.empty?
        @graph.scope.last.contains node
      end
    end
    
    def add_relation(s)
      s.slice(3..-1).each do |mod_sexp|
        node = @graph.node_for :module, mod_sexp, :not_sure_if_nested => true
        unless node.nil?
          if s[2] == :extend
            @graph.scope.last.extends node
          else
            @graph.scope.last.includes node
          end
        end
      end
    end
    
    # @return [Boolean] whether or not the walker should look for relations
    def find_relations?
      @mode == :find_relations
    end

  end
end
