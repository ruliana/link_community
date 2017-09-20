# frozen_string_literal: true

module LinkCommunity
  class UnweightedPartialLink
    attr_reader :node

    def initialize(link_class, node)
      @link_class = link_class
      @node = node
    end

    def indexify_with(graph)
      UnweightedPartialLink.new(@link_class, graph.find_index(@node))
    end

    def complete_with(other_node)
      @link_class.new(other_node, @node)
    end
  end
end
