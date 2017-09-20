# frozen_string_literal: true

module LinkCommunity
  class WeightedPartialLink
    attr_reader :node, :weight

    def initialize(link_class, node, weight)
      @link_class = link_class
      @node = node
      @weight = weight
    end

    def indexify_with(graph)
      WeightedPartialLink.new(@link_class, graph.find_index(@node), @weight)
    end

    def complete_with(other_node)
      @link_class.new(other_node, @node, @weight)
    end
  end
end
