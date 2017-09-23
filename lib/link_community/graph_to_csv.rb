# frozen_string_literal: true

require "csv"

module LinkCommunity
  class GraphToCsv
    def initialize(graph)
      @graph = graph
    end

    def to_csv(file_name)
      CSV.open(file_name, "w", headers: %w[from to weight], write_headers: true) do |csv|
        @graph.links_node.each do |link|
          csv << link.to_a
        end
      end
    end
  end
end
