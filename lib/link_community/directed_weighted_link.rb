# frozen_string_literal: true

module LinkCommunity
  class DirectedWeightedLink
    attr_reader :a, :b, :w

    def initialize(a, b, w)
      @a, @b, @w = a, b, w
    end

    def weight
      @w
    end

    def eql?(other)
      w == other.w && a == other.a && b == other.b
    end
    alias == eql?

    def hash
      @hash ||= to_a.hash
    end

    def to_a
      @to_a ||= [a, b, w]
    end

    def add_itself_to(graph)
      graph.add_link(a, WeightedPartialLink.new(self.class, b, w))
    end

    def nodify_with(graph)
      DLink(graph.find_node(a),
            graph.find_node(b),
            weight)
    end

    def indexify_with(graph)
      DLink(graph.find_index(a),
            graph.find_index(b),
            weight)
    end

    def inspect
      format("(%s)-[%0.1f]->(%s)", a, w, b)
    end

    def to_s
      inspect
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
      a_weights = weights_for(graph, not_shared_a)
      b_weights = weights_for(graph, not_shared_b)

      dot_prod = a_weights.sum { |k, v| b_weights.fetch(k, 0) * v }
      a_norm_squared = a_weights.sum { |_k, v| v**2 }
      b_norm_squared = b_weights.sum { |_k, v| v**2 }

      dot_prod / (a_norm_squared + b_norm_squared - dot_prod)
    end

    def weights_for(graph, index)
      partials = graph.neighbors_partial(index)
      return [] if partials.empty?
      weight = partials.sum(&:weight) / partials.size
      ([[index, weight]] + partials.map { |p| [p.node, p.weight] }).to_h
    end
  end
end
