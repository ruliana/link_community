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

    def nodify_with(graph)
      Link(graph.find_node(a),
           graph.find_node(b))
    end

    def indexify_with(graph)
      Link(graph.find_index(a),
           graph.find_index(b))
    end

    def share_nodes(other)
      other.share_not_share(a, b)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def share_not_share(c, d)
      # This method is odd due optimization!

      # Equivalent to (but way faster):
      # mine = to_a
      # [mine & other, mine ^ other]
      if a != c && a != d && b != c && b != d
        # Avoid memory allocation & calculation
        # for most common (and trivial) case
        # (huge gain here =/)
        SHARED_EMPTY
      elsif a == c && d != b
        Shared.new([a], [d, b])
      elsif a == d && c != b
        Shared.new([a], [c, b])
      elsif b == c && d != a
        Shared.new([b], [d, a])
      elsif b == d && c != a
        Shared.new([b], [c, a])
      else
        # Trivial case (same nodes)
        SHARED_MAX
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity

    def inspect
      format "(%s)-(%s)", a.inspect, b.inspect
    end
  end

  class SharedEmpty
    def similarity_on(_graph)
      0
    end
  end
  SHARED_EMPTY = SharedEmpty.new

  class SharedMax
    def similarity_on(_graph)
      1
    end
  end
  SHARED_MAX = SharedMax.new

  class Shared
    attr_reader :shared, :not_shared

    def initialize(shared, not_shared)
      @shared, @not_shared = shared, not_shared
    end

    def similarity_on(graph)
      return 0 if @shared.empty?
      neigh = neighbors(graph)
      shared_neighbors = neigh.reduce { |set, n| set & n }
      all_neighbors = neigh.flatten(1).uniq
      shared_neighbors.size / all_neighbors.size.to_f
    end

    private

    def neighbors(graph)
      @not_shared.map { |n| graph.neighbors_me(n) }
    end
  end
end
