# frozen_string_literal: true

module LinkCommunity
  class DirectedLink
    attr_reader :a, :b

    def initialize(a, b)
      @a, @b = a, b
    end

    def eql?(other)
      a == other.a && b == other.b
    end
    alias == eql?

    def hash
      @hash ||= to_a.hash
    end

    def to_a
      @to_a ||= [a, b]
    end

    def add_itself_to(graph)
      graph.add_link(a, UnweightedPartialLink.new(self.class, b))
    end

    def nodify_with(graph)
      DLink(graph.find_node(a),
            graph.find_node(b))
    end

    def indexify_with(graph)
      DLink(graph.find_index(a),
            graph.find_index(b))
    end

    def similarity_on(other, with:)
      # This enumerates each case and avoids
      # to allocate objects due performance.
      # Ronie Uliana 2017-09-14
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
