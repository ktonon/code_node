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
    root = Cog::Config.instance.project_source_path
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
      puts "#{(pass+1).ordinalize} pass: #{mode.to_s.gsub('_', ' ')}".color(:cyan)
      
      Dir.glob("#{root}/**/*.rb").each_with_index do |filename, i|
        sexp[i] ||= begin
          rp.parse(File.read filename)
        rescue Racc::ParseError
          STDERR.write "{filename.relative_to_project_root}, skipped...\n".color(:red)
          nil
        end
        if sexp[i]
          walker = SexpWalker.new @graph, sexp[i], :mode => mode
          walker.walk
        end
      end
    end
    
    # Activate code_node while rendering templates
    # so that cog will be able to find code_node templates
    Cog::Config.instance.activate_tool 'code_node' do
      stamp 'code_node/graph.dot', "#{graph_name}.dot"
    end
    
    nil
  end
end
