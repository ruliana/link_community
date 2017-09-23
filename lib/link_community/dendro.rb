# frozen_string_literal: true

module LinkCommunity
  class DendroBuilder
    def initialize(seed)
      @seed = seed
      @index = {}
      index(@seed)
      yield self if block_given?
    end

    def rslt
      @seed
    end

    def push(level, *members)
      key, rslt = find_dendro_by(members)
      if rslt.level == level
        rslt.push(*members)
        index(rslt)
      elsif rslt.level > level
        element = Dendro.new(*members, level: level)
        rslt.members.delete(key)
        rslt.push(element)
        index(element)
      else
        raise "Can't add pack #{pack.inspect} to\n#{rslt.inspect} (pack is higher level)"
      end
    end

    private

    def find_dendro_by(members)
      key = members.detect { |m| @index.key?(m) }
      raise "Can't add pack level: #{level}, members: #{members.inspect}" if key.nil?
      [key, @index[key]]
    end

    def index(dendro)
      dendro.members.each { |m| @index[m] = dendro }
      dendro.children.each { |c| index(c) }
    end
  end

  def Dendro(level, members)
    Dendro.new(*members, level: level)
  end

  class Dendro
    attr_reader :level, :members, :children

    def initialize(*members, level: Float::INFINITY)
      @level = level
      @members = Set.new
      @children = Set.new
      members.each { |m| push(m) }
    end

    EMPTY = Dendro.new

    def ==(other)
      ((level == other.level) ||
       (level - other.level).abs < 0.01) &&
        members == other.members &&
        children == other.children
    end
    alias eql? ==

    def hash
      # We want to compare groups "close enough" on tests
      [format("%0.2f", level), members, children.hash].hash
    end

    def inspect
      format("Dendro(%0.2f, [%s])", level, (members.to_a + children.to_a.map(&:inspect)).join(", "))
    end

    def push(*others)
      others.each { |e| push_one(e) }
    end

    def map
      return enum_for(:map) unless block_given?
      new_members = members.map { |m| yield m }
      new_children = children.map { |c| c.map { |e| yield e } }
      Dendro.new(*(new_members + new_children), level: level)
    end

    # Groups splitted by _at least_ the desired level
    def cut_by_level(desired)
      if desired > level
        [all_members]
      else
        members.map { |m| [m] } + @children.flat_map { |c| c.cut_by_level(desired) }
      end
    end

    def all_members
      children.reduce(members.to_a) do |rslt, c|
        rslt + c.all_members
      end
    end
  end

  private

  def push_one(other)
    if other.is_a?(Dendro)
      push_trunk(other)
    else
      members << other
    end
  end

  def push_trunk(other)
    if other.level == level
      members.merge(other.members)
    elsif other.level < level
      children << other
    else
      raise "Can't push to a higher trunk"
    end
  end
end
