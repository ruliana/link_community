# frozen_string_literal: true

module LinkCommunity
  def Link(a, b)
    Link.new(a, b)
  end

  Link = Struct.new(:a, :b) do
    def add_itself_to(graph)
      graph.add_link(a, b)
      graph.add_link(b, a)
    end

    def share_nodes(other)
      shared, not_shared = other.share_not_share(a, b)
      Shared.new(shared, not_shared)
    end

    def share_not_share(*nodes)
      mine = Set[a, b]
      others = Set.new(nodes)
      [mine & others, mine ^ others]
    end
  end

  Shared = Struct.new(:shared, :not_shared) do
    def similarity_on(graph)
      return 0 if shared.empty?
      neighbors = not_shared.map { |n| graph.neighbors_me(n) }
      shared_neighbors = neighbors.reduce { |set, n| set & n }
      all_neighbors = neighbors.reduce { |set, n| set + n }
      shared_neighbors.size / all_neighbors.size.to_f
    end
  end
end
