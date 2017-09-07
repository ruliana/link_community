# frozen_string_literal: true

require "csv"

module LinkCommunity
  class CsvToGraph
    def initialize(file_name)
      @file_name = file_name
    end

    def to_graph
      Graph.build do |graph|
        open(@file_name) do |file|
          CSV.new(file, headers: true).each do |row|
            graph.add(Link(row[0], row[1]))
          end
        end
      end
    end
  end
end
