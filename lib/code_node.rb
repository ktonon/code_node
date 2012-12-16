$LOAD_PATH << File.join(File.dirname(__FILE__))
require 'code_node/version'
require 'code_node/dsl'
require 'code_node/graph_builder'
require 'code_node/ir'
require 'code_node/sexp_walker'
require 'cog'
require 'ruby_parser'

# Create Class and Module graphs for Ruby prjects
module CodeNode
  
  extend Cog::Generator
  
  # @param graph_name [String] name of the dot file to generate (without +.dot+ extension)
  # @option opt [Symbol] :ruby_version (:ruby19) either <tt>:ruby18</tt> or <tt>:ruby19</tt>, indicating which parser to use
  # @yieldparam graph [DSL::GraphDefiner] define rules for creating the graph
  def self.graph(graph_name, opt={}, &block)
    parser = if opt[:ruby_version] == :ruby18
      Ruby18Parser.new
    else
      Ruby19Parser.new
    end

    GraphBuilder.new(graph_name, parser).
      define(&block).
      find_nodes.
      find_relations.
      finalize.
      render
  end
  
end
