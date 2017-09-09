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

    def dendro
      @dendro ||= begin
                    first, *rest = @packs
                    lvl, a, b = first
                    seed = Dendro.new(a, b, level: lvl)
                    builder = DendroBuilder.new(seed)
                    rest.each { |p| builder.push(p) }
                    builder.rslt
                  end
    end

    private

    def build_packs(heights)
      heights.each_with_index
             .map { |h, i| [h, @data[i], @data[@parents[i]]] }
             .sort_by { |h, *_| h }
             .reverse
             .drop(1) # Drop "infinity"
    end

    def build_groups(packs)
      level, a, b = packs.first
      head = Group.new(level, a, b)
      packs.drop(1).each do |pack|
        level, a, b = pack
        pack = Group.new(level, a, b)
        head.push(pack)
      end
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
      members = members.flat_map do |m|
        if m.is_a?(Group) && m.level == level
          m.members.to_a
        else
          m
        end
      end
      @members = Set.new(members.compact)
    end

    def ==(other)
      level == other.level && members == other.members
    end
    alias eql? ==

    def hash
      [level, members].hash
    end

    def nodify_with(graph)
      new_members = members.map do |member|
        if member.respond_to?(:nodify_with)
          member.nodify_with(graph)
        else
          graph.find_node(member)
        end
      end
      Group.new(level, *new_members)
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
