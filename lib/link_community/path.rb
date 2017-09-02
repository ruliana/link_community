# frozen_string_literal: true

module LinkCommunity
  def Path(*nodes)
    Path.new(nodes)
  end

  class Path
    def initialize(nodes)
      @nodes = nodes
    end

    def add_itself_to(graph)
      @nodes.each_cons(2) do |a, b|
        graph.add_link(a, b)
        graph.add_link(b, a)
      end
    end
  end
end
