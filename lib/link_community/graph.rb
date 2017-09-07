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
      rslt = Set.new
      @graph.each do |node, neighbors|
        neighbors.each do |other|
          rslt << Link(node, other)
        end
      end
      rslt
    end

    def neighbors(v)
      @graph.fetch(v, EMPTY_SET)
    end

    def neighbors_me(v)
      @neighbors_me ||= Hash.new { |h, k| h[k] = Set[k] + neighbors(k) }
      @neighbors_me[v]
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
