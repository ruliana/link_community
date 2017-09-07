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
      @nodes ||= @raw_links.flatten(1).uniq.sort.freeze
    end

    def edge_list
      @edge_list ||= begin
                       rslt = Array.new(nodes_size) { [] }

                       @raw_links.uniq.map do |(a, b)|
                         a_index = find_index(a)
                         b_index = find_index(b)
                         rslt[a_index] << b_index
                         rslt[b_index] << a_index
                       end

                       rslt.map!(&:uniq).each(&:freeze).freeze
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
      @links_index ||= begin
                         rslt = []
                         edge_list.each_with_index do |edges, a|
                           edges.each { |b| rslt << Link(a, b) }
                         end
                         rslt.uniq.freeze
                       end
    end

    def links_node
      @links_node ||= links_index.map { |link| Link(find_node(link.a), find_node(link.b)) }.freeze
    end

    def neighbors_index(index)
      edge_list.fetch(index, [])
    end

    def neighbors_node(node)
      index = find_index(node)
      return [] if index.nil?
      edge_list.fetch(index, []).map { |i| find_node(i) }.compact
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
      share = link1.share_nodes(link2)
      share.similarity_on(self)
    end

    def link_community
      slink = Slink.new(links_index)
      slink.call { |a, b| 1 - similarity(a, b) }
    end
  end
end
