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

    def groups
      @groups ||= begin
                    first, *rest = @packs
                    mount(rest, first)
                  end
    end

    private

    def build_packs(heights)
      heights.each_with_index
             .map { |h, i| [h, @data[i], @data[@parents[i]]] }
             .sort_by { |h, *_| h }
             .reverse
             .drop(1) # Drop infinity
    end

    def mount(packs, head)
      level, a, b = head
      return Group.new(level, a, b) if packs.empty?

      a = build(packs, a)
      b = build(packs, b)

      Group.new(level, a, b)
    end

    def build(packs, element)
      rslt = packs.drop_while { |_, left, right| left != element && right != element }
      return element if rslt.empty?

      first, *rest = rslt
      mount(rest, first)
    end
  end

  class Group
    attr_reader :level, :members

    def initialize(level = nil, *members)
      @level = level || Float::INFINITY
      @members = Set.new(members.compact)
    end

    def ==(other)
      level == other.level && members == other.members
    end
    alias eql? ==

    def hash
      [level, members].hash
    end

    def inspect
      return "()" if members.empty?
      format("([%0.2f], %s)", level, members.map(&:inspect).join(", "))
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

      start = Time.now
      counter = 1
      puts "start #{size}"
      printf "Passed: %6dr, %6.1fs, %6.2fr/s, eta %6dmin", 0, 0, 0, 0
      size.times do |n|
        counter += 1
        elapsed = Time.now - start
        if (counter % 100).zero?
          printf "\b" * 51
          printf "Passed: %6dr, %6.1fs, %6.2fr/s, eta %6dmin",
                 counter,
                 elapsed,
                 counter / elapsed.to_f,
                 size / (counter / elapsed.to_f) / 60
          STDOUT.flush
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

      Dendrogram.new(@data, height, parent)
    end
  end
end
