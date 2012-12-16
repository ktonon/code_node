$LOAD_PATH << File.join(File.dirname(__FILE__))
require 'code_node/version'
require 'code_node/dsl'
require 'code_node/ir'
require 'code_node/sexp_walker'
require 'cog'
require 'ruby_parser'

# Create Class and Module graphs for Ruby prjects
module CodeNode
  
  extend Cog::Generator
  
  # @param graph_name [String] name of the dot file to generate (without +.dot+ extension)
  # @option opt [Symbol] :ruby_version (:ruby19) either <tt>:ruby18</tt> or <tt>:ruby19</tt>, indicating which parser to use
  # @yield [GraphDefinition] define rules for creating the graph
  def self.graph(graph_name, opt={}, &block)
    feedback_color = :white
    root = Cog.project_source_path
    @graph = IR::Graph.new
    graph_definer = DSL::GraphDefiner.new @graph
    block.call graph_definer

    rp = case opt[:ruby_version]
    when :ruby18
      Ruby18Parser.new
    else
      Ruby19Parser.new
    end

    sexp = []
    [:find_nodes, :find_relations].each_with_index do |mode, pass|
      puts "#{(pass+1).ordinalize} pass: #{mode.to_s.gsub('_', ' ')}".color(feedback_color)
      Dir.glob("#{root}/**/*.rb").each_with_index do |filename, i|
        sexp[i] ||= begin
          rp.parse(File.read filename)
        rescue Racc::ParseError
          STDERR.write "#{filename.relative_to_project_root}, skipped...\n".color(:yellow)
          nil
        end
        if sexp[i]
          walker = SexpWalker.new @graph, sexp[i], :mode => mode
          walker.walk
        end
      end
    end

    # Apply styles before pruning because some relations may be destroyed while pruning
    puts "Applying styles".color(feedback_color)
    @graph.apply_styles

    # Prune the graph according to ignore rules.
    # We keep pruning until there are no more changes because some rules don't apply the first time (for example: &:island?)
    puts "Pruning nodes".color(feedback_color)
    i = 1
    while (x = @graph.prune) > 0
      puts "  #{x} nodes pruned on #{i.ordinalize} pass".color(feedback_color)
      i += 1
    end
    
    # Activate code_node while rendering templates
    # so that cog will be able to find code_node templates
    Cog.activate_tool 'code_node' do
      stamp 'code_node/graph.dot', "#{graph_name}.dot"
    end
    
    nil
  end
end
