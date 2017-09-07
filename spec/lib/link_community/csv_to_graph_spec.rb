# frozen_string_literal: true

require "spec_helper"

describe CsvToGraph do
  FIXTURES = File.join(__dir__, "../../fixtures")

  it "reads a single line" do
    graph = CsvToGraph.new(File.join(FIXTURES, "one_line_edge_list.csv")).to_graph
    expect(graph.links_node).to match_array([Link("a", "b")])
  end

  it "reads more lines" do
    graph = CsvToGraph.new(File.join(FIXTURES, "multi_line_edge_list.csv")).to_graph
    expect(graph.links_node).to match_array([Link("a", "b"),
                                             Link("b", "c"),
                                             Link("c", "d")])
  end
end
