# frozen_string_literal: true

module LinkCommunity
  class Graph
    def initialize
      @graph = Hash.new { |k, v| k[v] = EMPTY_SET }
    end

    def add(*links)
      links.each { |link| link.add_itself_to(self) }
      self
    end

    def add_link(a, b)
      @graph[a] += Set(b)
      self
    end

    def neighbors(v)
      @graph.fetch(v, EMPTY_SET)
    end

    def neighbors_me(v)
      Set[v] + neighbors(v)
    end

    def similarity(link1, link2)
      share = link1.share_nodes(link2)
      share.similarity_on(self)
    end
  end
end
