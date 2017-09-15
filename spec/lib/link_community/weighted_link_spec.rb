# frozen_string_literal: true

require "spec_helper"

describe WeightedLink do
  it "has functional constructor" do
    expect(Link(1, 2, 99)).to be_kind_of(WeightedLink)
  end

  describe "#==" do
    it "is equal no matter the order" do
      expect(Link(1, 2, 99)).to eq(Link(2, 1, 99))
      expect(Link(1, 7, 99)).not_to eq(Link(1, 2, 99))
    end

    it "is NOT equal if weight is different" do
      expect(Link(1, 2, 98)).not_to eq(Link(1, 2, 99))
      expect(Link(1, 2, 98)).not_to eq(Link(2, 1, 99))
    end
  end
end
