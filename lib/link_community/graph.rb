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

    def links
      pairs_of_nodes = @graph.reduce(Set()) do |set, (node, neighbors)|
        set + neighbors.map { |other| Set(node, other) }.to_set
      end

      pairs_of_nodes.map do |nodes|
        Link(*nodes)
      end.to_set
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

    def link_community
      slink = Slink.new(links.to_a)
      slink.call { |a, b| 1 - similarity(a, b) }
    end
  end
end
