require 'cog'
require 'code_node/ir/graph'

module CodeNode
  
  # Helps to build an {IR::Graph}
  class GraphBuilder
    
    # @return [IR::Graph] the graph being built
    attr_reader :graph
    
    # @param name [String] the name of the graph
    # @param parser [Ruby18Parser, Ruby19Parser] a ruby parser instance
    def initialize(name, parser)
      @name = name
      @graph = IR::Graph.new
      @parser = parser
      @sexp = [] # array of file sexp, one per file
    end
    
    # @return [Array<String>] paths to ruby source files
    def sources
      Dir.glob("#{Cog.project_source_path}/**/*.rb")
    end
    
    # Define the custom graph generation rules
    # @return [self]
    def define(&block)
      block.call DSL::GraphDefiner.new(@graph)
      self
    end
    
    # Search the sources for nodes
    # @return [self]
    def find_nodes
      puts '1st pass: find nodes'
      find :nodes
      self
    end
    
    # Search the sources for relations
    # @return [nil]
    def find_relations
      puts '2nd pass: find relations'
      find :relations
      self
    end

    # Apply styles and prune the graph
    # @return [nil]
    def finalize
      # Apply styles before pruning because some relations may be destroyed while pruning
      puts "Applying styles"
      @graph.apply_styles

      # Prune the graph according to ignore rules.
      # We keep pruning until there are no more changes because some rules don't apply the first time (for example: &:island?)
      puts "Pruning nodes"
      i = 1
      while (x = @graph.prune) > 0
        puts "  #{x} nodes pruned on #{i.ordinalize} pass"
        i += 1
      end
      self
    end

    # Render the graph
    # @return [nil]
    def render
      # Activate code_node while rendering templates
      # so that cog will be able to find code_node templates
      Cog.activate_tool 'code_node' do
        stamp 'code_node/graph.dot', "#{@name}.dot"
      end
      nil
    end
    
    private
    
    # @param type [Symbol] one of <tt>:nodes</tt> or <tt>:relations</tt>
    # @return [nil]
    def find(type)
      sources.each_with_index do |filename, i|
        @sexp[i] ||= parse filename
        if @sexp[i]
          walker = SexpWalker.new @graph, @sexp[i], :mode => "find_#{type}".to_sym
          walker.walk
        end
      end
      nil
    end

    # @param filename [String] path to the file to parse
    # @return [Sexp]
    def parse(filename)
      @parser.parse(File.read filename)
    rescue Racc::ParseError
      STDERR.write "#{filename.relative_to_project_root}, skipped...\n".color(:yellow)
      nil
    end
  end
end
