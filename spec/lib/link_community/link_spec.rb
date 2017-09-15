# frozen_string_literal: true

require "spec_helper"

describe Link do
  it "has functional constructor" do
    expect(Link(1, 2)).to eq(Link(1, 2))
  end

  describe "#==" do
    it "is equal no matter the order" do
      expect(Link(1, 2)).to eq(Link(1, 2))
      expect(Link(1, 2)).to eq(Link(2, 1))
    end
  end
end
