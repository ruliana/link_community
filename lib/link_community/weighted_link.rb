# frozen_string_literal: true

module LinkCommunity
  class WeightedLink
    attr_accessor :a, :b, :w

    def initialize(a, b, w)
      @a, @b, @w = a, b, w
    end

    def weight
      @w
    end

    def eql?(other)
      w == other.w && (
        (a == other.a && b == other.b) || (b == other.a && a == other.b)
      )
    end
    alias == eql?

    def hash
      @hash ||= [Set(a, b), w].hash
    end

    def add_itself_to(graph)
      graph.add_link(self)
      graph.add_link(Link(b, a, w))
    end

    def similarity_on(other, with:)
      c, d = other.a, other.b
      graph = with

      if a != c && a != d && b != c && b != d
        0
      elsif a == c && d != b
        similarity_with(graph, d, b)
      elsif a == d && c != b
        similarity_with(graph, c, b)
      elsif b == c && d != a
        similarity_with(graph, d, a)
      elsif b == d && c != a
        similarity_with(graph, c, a)
      else
        1
      end
    end

    private

    def similarity_with(graph, not_shared_a, not_shared_b)
      neigh_a = graph.neighbors_me(not_shared_a)
      neigh_b = graph.neighbors_me(not_shared_b)

      shared_neighbors = neigh_a & neigh_b
      all_neighbors = (neigh_a + neigh_b).uniq

      shared_neighbors.size / all_neighbors.size.to_f
    end
  end
end
