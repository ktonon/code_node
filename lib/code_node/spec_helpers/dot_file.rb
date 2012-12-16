module CodeNode
  module SpecHelpers
    
    # Represents a generated dot file
    class DotFile
      
      include Cog::SpecHelpers
      
      # @param name [String] name of the dotfile without the <tt>.dot</tt> extension. The file will be looked for in the lib subdirectory of the active fixture dir.
      def initialize(name)
        @filename = generated_file "#{name}.dot"
        @nodes = {} # :node_type => []
        @edges = {} # :edge_type => []
        if File.exists? @filename
          @i = 0
          @lines = File.read(@filename).split "\n"
          read_until '/* Module nodes */'
          read_nodes :module
          read_until '/* Class nodes */'
          read_nodes :class
          read_until '/* A contains B */'
          read_edges :containment
          read_until '/* A inherits from B */'
          read_edges :inheritance
          read_until '/* A includes B */'
          read_edges :inclusion
          read_until '/* A extends B */'
          read_edges :extension
        end
      end
      
      # @return [Boolean] does the file exist?
      def exists?
        File.exists? @filename
      end
      
      def has_match?(pattern)
        if exists?
          !!(pattern =~ File.read(@filename))
        end
      end
      
      def has_node?(path)
        has_class?(path) || has_module?(path)
      end
      
      def has_class?(path)
        key = path.to_s.split('::').join '_'
        @nodes[:class].member?(key)
      end

      def has_module?(path)
        key = path.to_s.split('::').join '_'
        @nodes[:module].member?(key)
      end

      def has_edge?(path1, path2)
        has_containment?(path1, path2) || has_inheritance?(path1, path2) || has_inclusion?(path1, path2) || has_extension?(path1, path2)
      end
      
      def has_containment?(path1, path2)
        has_relation? :containment, path1, path2
      end

      def has_inheritance?(path1, path2)
        has_relation? :inheritance, path1, path2
      end

      def has_inclusion?(path1, path2)
        has_relation? :inclusion, path1, path2
      end

      def has_extension?(path1, path2)
        has_relation? :extension, path1, path2
      end
      
      private
      
      def read_nodes(type)
        @nodes[type] ||= []
        until (line = @lines[@i]).strip.empty?
          /^([A-Za-z0-9_]+)/ =~ line
          @nodes[type] << $1 unless $1.nil?
          @i += 1
        end
      end
      
      def read_edges(type)
        @edges[type] ||= []
        until (line = @lines[@i]).strip.empty?
          /^([A-Za-z0-9_]+)\s\-\>\s([A-Za-z0-9_]+)/ =~ line
          @edges[type] << [$1, $2] unless $1.nil?
          @i += 1
        end
      end
      
      def read_until(line)
        while @lines[@i] != line && @i < @lines.length
          @i += 1
        end
        @i += 1
      end
      
      def has_relation?(relation, path1, path2)
        key1 = path1.to_s.split('::').join '_'
        key2 = path2.to_s.split('::').join '_'
        @edges[relation].member?([key1, key2])
      end
    end
    
  end
end