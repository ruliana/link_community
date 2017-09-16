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
        Link(a, b).add_itself_to(graph)
      end
    end
  end
end
