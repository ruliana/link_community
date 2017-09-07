# frozen_string_literal: true

module LinkCommunity
  def Link(a, b)
    Link.new(a, b)
  end

  class Link
    using ArrayRefinement

    attr_accessor :a, :b

    def initialize(a, b)
      @a, @b = a, b
    end

    def eql?(other)
      (a == other.a && b == other.b) || (b == other.a && a == other.b)
    end
    alias == eql?

    def hash
      @hash ||= Set(a, b).hash
    end

    def to_a
      @to_a ||= [a, b]
    end

    def add_itself_to(graph)
      graph.add_link(a, b)
      graph.add_link(b, a)
    end

    def share_nodes(other)
      shared, not_shared = other.share_not_share(to_a)
      Shared.new(shared, not_shared)
    end

    def share_not_share(others)
      mine = to_a
      [mine & others, mine ^ others]
    end

    def inspect
      format "(%s)-(%s)", a.inspect, b.inspect
    end
  end

  Shared = Struct.new(:shared, :not_shared) do
    def similarity_on(graph)
      return 0 if shared.empty?
      neighbors = not_shared.map { |n| graph.neighbors_me(n).to_a }
      shared_neighbors = neighbors.reduce { |set, n| set & n }
      all_neighbors = neighbors.flatten(1).uniq
      shared_neighbors.size / all_neighbors.size.to_f
    end
  end
end
