# frozen_string_literal: true

module LinkCommunity
  class Graph
    def self.build
      builder = GraphBuilder.new
      yield builder
      builder.build
    end

    def initialize(links)
      @raw_links = links
    end

    def nodes
      @nodes ||= @raw_links.flat_map { |from, to_reference| [from, to_reference.node] }
                           .uniq.sort.freeze
    end

    def edge_list
      @edge_list ||= begin
                       rslt = Array.new(nodes_size) { {} }

                       @raw_links.map do |(from, partial)|
                         a = find_index(from)
                         partial = partial.indexify_with(self)
                         rslt[a][partial.node] = partial
                       end

                       rslt.each(&:freeze).freeze
                     end
    end

    def find_node(index)
      nodes[index]
    end

    def find_index(node)
      nodes.bsearch_index do |n|
        if    node < n then -1
        elsif node > n then 1
        else 0
        end
      end
    end

    def links_index
      @links_index ||= edge_list.each_with_index
                                .flat_map do |partials, from_node|
        partials.values.map do |partial|
          partial.complete_with(from_node)
        end
      end.uniq
    end

    def links_node
      @links_node ||= links_index.map { |link| link.nodify_with(self) }.freeze
    end

    def neighbors_index(index)
      @neighbors_index ||= Array.new(nodes_size)
      @neighbors_index[index] ||= edge_list.fetch(index, {}).keys
    end

    def neighbors_node(node)
      index = find_index(node)
      neighbors_index(index).map { |i| find_node(i) }
    end

    def nodes_size
      nodes.size
    end

    def neighbors_partial(index)
      edge_list.fetch(index, {}).values
    end

    def neighbors_me(index)
      @neighbors_me ||= Array.new(nodes_size)
      @neighbors_me[index] ||= [index] + neighbors_index(index)
    end

    def similarity_node(link1, link2)
      similarity(link1.indexify_with(self),
                 link2.indexify_with(self))
    end

    def similarity(link1, link2)
      link_a = edge_list[link1.a].fetch(link1.b).complete_with(link1.a)
      link_b = edge_list[link2.a].fetch(link2.b).complete_with(link2.a)
      link_a.similarity_on(link_b, with: self)
    end

    def link_community
      slink = Slink.new(links_index)
      slink.call { |a, b| 1 - similarity(a, b) }
    end

    def dendrogram
      link_community.dendrogram.nodify_with(self)
    end
  end
end
