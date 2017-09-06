# frozen_string_literal: true

require "spec_helper"

describe Slink do
  distance = ->(a, b) { (a - b).abs }

  context "with no element" do
    subject { Slink.new([]).call }

    it "returns empty group" do
      expect(subject.levels).to eq({})
      expect(subject.groups).to eq(Group.new)
    end
  end

  context "with one element" do
    subject { Slink.new([1]).call }

    it "returns no group (odd, but there it is)" do
      expect(subject.levels).to eq({})
      expect(subject.groups).to eq(Group.new)
    end
  end

  context "with two elements" do
    subject { Slink.new([8, 9]).call(&distance) }

    it "returns a single group" do
      expect(subject.groups).to eq(Group.new(1, 8, 9))
    end
  end

  context "with [1, 8, 9]" do
    subject { Slink.new([1, 8, 9]).call(&distance) }

    it "groups as [1, [8, 9]]" do
      expect(subject.groups).to eq(Group.new(7, 1, Group.new(1, 8, 9)))
    end
  end

  context "with [9, 1, 8]" do
    subject { Slink.new([9, 1, 8]).call(&distance) }

    it "groups as [1, [8, 9]]" do
      expect(subject.groups).to eq(Group.new(7, 1, Group.new(1, 8, 9)))
    end
  end

  context "with [9, 1, 8, 2]" do
    subject { Slink.new([9, 1, 8, 2, 5, 4]).call(&distance) }

    it "groups as [[8, 9], [[1,2], [3, 4]]]" do
      expect(subject.levels).to eq(3 => 1, 2 => 1, 1 => 3)
      expect(subject.groups).to eq(Group.new(3,
                                             Group.new(1, 8, 9),
                                             Group.new(2,
                                                       Group.new(1, 1, 2),
                                                       Group.new(1, 4, 5))))
    end
  end
end
