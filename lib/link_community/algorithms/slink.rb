# frozen_string_literal: true

module LinkCommunity
  class Dendrogram
    def initialize(data, heights, parents)
      @data = data
      @parents = parents
      @packs = build_packs(heights)
    end

    def levels
      @levels ||= @packs.group_by { |h, _i| h }.transform_values(&:size)
    end

    def dendro
      @dendro ||= begin
                    if @packs.empty?
                      Dendro.new
                    else
                      build_dendogram(@packs)
                    end
                  end
    end
    alias dendrogram dendro

    private

    def build_dendogram(packs)
      first, *rest = packs
      lvl, a, b = first
      seed = Dendro.new(a, b, level: lvl)
      builder = DendroBuilder.new(seed)
      rest.each { |pack| builder.push(*pack) }
      builder.rslt
    end

    def build_packs(heights)
      heights.each_with_index
             .map { |h, i| [h, @data[i], @data[@parents[i]]] }
             .sort_by { |h, *_| h }
             .reverse
             .drop(1) # Drop "infinity"
    end
  end

  class Slink
    def initialize(data)
      @data = data
    end

    def call
      size = @data.size

      return Dendrogram.new(@data, [Float::INFINITY], @data) if @data.size == 1

      height = Array.new(size)
      parent = Array.new(size)
      distance_to_n = Array.new(size)

      monitor = ConsoleMonitor.new("%s\t%s\n", size)
      size.times do |n|
        monitor.printf do |m|
          [m.counter, m.elapsed]
        end

        parent[n] = n
        height[n] = Float::INFINITY

        n.times do |i|
          distance_to_n[i] = yield(@data[i], @data[n])
        end

        n.times do |i|
          if height[i] >= distance_to_n[i]
            distance_to_n[parent[i]] = [distance_to_n[parent[i]], height[i]].min
            height[i] = distance_to_n[i]
            parent[i] = n
          else
            distance_to_n[parent[i]] = [distance_to_n[parent[i]], distance_to_n[i]].min
          end
        end

        n.times do |i|
          parent[i] = n if height[i] >= height[parent[i]]
        end
      end
      monitor.finish

      Dendrogram.new(@data, height, parent)
    end
  end
end
