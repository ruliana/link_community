# frozen_string_literal: true

require "spec_helper"

describe DirectedLink do
  it "has functional constructor" do
    expect(DLink(1, 2)).to eq(DLink(1, 2))
    expect(DLink(1, 2, 99)).to eq(DLink(1, 2, 99))
  end

  describe "#==" do
    it "is equal no matter the order" do
      expect(DLink(1, 2)).to eq(DLink(1, 2))
      expect(DLink(1, 2, 99)).to eq(DLink(1, 2, 99))

      expect(DLink(1, 2)).not_to eq(DLink(2, 1))
      expect(DLink(1, 2, 99)).not_to eq(DLink(2, 1, 99))
    end
  end
end
