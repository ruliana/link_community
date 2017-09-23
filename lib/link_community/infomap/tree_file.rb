# frozen_string_literal: true

module LinkCommunity
  class TreeFile
    include Enumerable

    def self.read(file_name)
      new do |builder|
        File.foreach(file_name) do |line|
          match = line.match(/^((?:\d+:)+)\d+.*?(\d+)$/)
          next if match.nil?
          communities = match[1].split(":").compact.map(&:to_i)
          communities = (1..communities.size).map { |i| communities[0..(i - 1)].join(":") }
          node_index = match[2].to_i
          builder.add(communities, node_index)
        end
      end
    end

    def initialize
      @communities = Hash.new { |h, k| h[k] = Set.new }
      @nodes = Hash.new { |h, k| h[k] = Set.new }
      yield self
    end

    def add(communities, node_index)
      Array(communities).each do |comm|
        @communities[comm] << node_index
        @nodes[node_index] << comm
      end
    end

    def each
      enum :each unless block_given?
      @communities.each { |k, v| yield(k, v) }
    end

    def communities
      @communities.keys
    end

    def select_communities(communities)
      communities = Array(communities)
      self.class.new do |builder|
        @communities.lazy
                    .select { |comm, _nodes| communities.include?(comm) }
                    .each do |comm, nodes|
                      nodes.each { |n| builder.add(comm, n) }
                    end
      end
    end

    def communities_for(node_index)
      @nodes.fetch(node_index, Set.new)
    end
  end
end
