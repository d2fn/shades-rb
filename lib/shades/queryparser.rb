require "treetop"

module Shades
  module QueryGrammar
    class QueryNode < Treetop::Runtime::SyntaxNode
      def rollup_nodes
        rollup_list.to_a
      end

      def categorization_nodes
        categorization_list.to_a
      end

      def sorting_nodes
        if optional_sorting.respond_to?(:sorting_list)
          optional_sorting.sorting_list.to_a
        else
          []
        end
      end
    end

    class RollupListNode < Treetop::Runtime::SyntaxNode
      def to_a
        [rollup] + rest_rollups.elements.map do |comma_and_rollup|
          comma_and_rollup.rollup
        end
      end
    end

    class IdentifierListNode < Treetop::Runtime::SyntaxNode
      def to_a
        [identifier] + rest_identifiers.elements.map do |comma_and_identifier|
          comma_and_identifier.identifier
        end
      end
    end

    class RollupNode < Treetop::Runtime::SyntaxNode
      def stat_type_name
        stat_type.text_value
      end

      def measure_names
        measures.to_a.map(&:text_value)
      end
    end

    class StatTypeNode < Treetop::Runtime::SyntaxNode
    end

    class IdentifierNode < Treetop::Runtime::SyntaxNode
      def name
        text_value
      end
    end
  end

  class QueryParser
    def self.parse(qs, query_factory = Query)
      @parser_class ||= Treetop.load(File.join(File.dirname(__FILE__), "query.treetop"))

      parser = @parser_class.new
      unless query_node = parser.parse(qs)
        raise ArgumentError, "Cannot parse query at character #{parser.index}"
      end

      query_factory.new(
        :rollups         => rollups_from_nodes(query_node.rollup_nodes),
        :categorizations => categorizations_from_nodes(query_node.categorization_nodes),
        :sorting         => sorting_from_nodes(query_node.sorting_nodes)
      )
    end

    def self.rollups_from_nodes(nodes)
      nodes.flat_map { |node|
        stat = Stats::StatsType.get(node.stat_type_name)
        node.measure_names.map { |measure_name|
          { :stat => stat, :measure => measure_name }
        }
      }
    end

    def self.categorizations_from_nodes(nodes)
      nodes.map { |categorization|
        categorization.name
      }
    end

    def self.sorting_from_nodes(nodes)
      nodes.map { |sorting|
        { :key => sorting.name, :asc => true }
      }
    end
  end
end
