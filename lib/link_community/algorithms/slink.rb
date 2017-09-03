# frozen_string_literal: true

module LinkCommunity
  class Group
    attr_reader :level, :members

    def initialize(level = nil, *members)
      @level = level || Float::INFINITY
      @members = Set.new(members.compact)
    end

    def ==(other)
      level == other.level && members == other.members
    end

    def eql?(other)
      level == other.level && members == other.members
    end

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

      return Group.new if @data.empty?
      return Group.new(Float::INFINITY, @data.first) if @data.size == 1

      height = Array.new(size)
      parent = Array.new(size)
      distance_to_n = Array.new(size)

      size.times do |n|
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

      pack(height, parent)
    end

    private

    def pack(height, parent)
      packs = height.each_with_index
                    .map { |h, i| [h, @data[i], @data[parent[i]]] }
                    .sort_by { |h, *_| h }
                    .reverse
                    .drop(1) # Drop infinity

      first, *rest = packs
      mount(rest, first)
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
end
