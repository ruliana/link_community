# frozen_string_literal: true

module LinkCommunity
  class DendroBuilder
    def initialize(seed)
      @seed = seed
      @index = {}
      push_dendro(@seed)
      yield self if block_given?
    end

    def rslt
      @seed
    end

    def push_dendro(dendro)
      dendro.members.each { |m| @index[m] = dendro }
      dendro.children.each { |c| push_dendro(c) }
    end

    def push(pack)
      level, a, b = pack
      rslt = @index[a] || @index[b]
      raise "Can't add pack #{pack.inspect}" if rslt.nil?

      rslt = if rslt.level == level
               rslt
             elsif rslt.level > level
               rslt.members.delete(a)
               rslt.members.delete(b)
               element = Dendro.new(level: level)
               rslt.children << element
               element
             else
               raise "Can't add pack #{pack.inspect} to\n#{rslt.inspect}"
             end

      rslt.members << a
      rslt.members << b

      @index[a] = rslt
      @index[b] = rslt

      rslt
    end
  end

  class Dendro
    attr_reader :level, :members, :children

    def initialize(*members, level: Float::INFINITY)
      @level = level
      @members = Set.new
      @children = Set.new
      members.each { |m| push(m) }
    end

    def ==(other)
      level == other.level &&
        members == other.members &&
        children == other.children
    end
    alias eql? ==

    def hash
      [level, members, children.hash].hash
    end

    def push(other)
      if other.is_a?(Dendro)
        push_trunk(other)
      else
        members << other
      end
    end
  end

  private

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
