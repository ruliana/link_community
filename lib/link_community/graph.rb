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
      @nodes ||= @raw_links.flat_map { |link| [link.a, link.b] }.uniq.sort.freeze
    end

    def edge_list
      @edge_list ||= begin
                       rslt = Array.new(nodes_size) { [] }

                       @raw_links.map do |link|
                         link = link.indexify_with(self)
                         rslt[link.a] << link
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
      @links_index ||= edge_list.flatten(1).uniq.freeze
    end

    def links_node
      @links_node ||= links_index.map { |link| Link(find_node(link.a), find_node(link.b)) }.freeze
    end

    def neighbors_index(index)
      edge_list.fetch(index, []).map { |link| link.b }
    end

    def neighbors_node(node)
      index = find_index(node)
      neighbors_index(index).map { |i| find_node(i) }
    end

    def nodes_size
      nodes.size
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
      link1.similarity_on(link2, with: self)
    end

    def link_community
      slink = Slink.new(links_index)
      slink.call { |a, b| 1 - similarity(a, b) }
    end
  end
end
