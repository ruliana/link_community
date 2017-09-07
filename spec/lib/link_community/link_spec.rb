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

  describe "#share_nodes" do
    context "1-2 and 3-4" do
      subject { Link(1, 2).share_nodes(Link(3, 4)) }

      it "share nothing" do
        expect(subject.shared).to eq([])
      end

      it "does no share 1, 2, 3, 4" do
        expect(subject.not_shared).to match_array([1, 2, 3, 4])
      end
    end

    context "1-2 and 2-3" do
      subject { Link(1, 2).share_nodes(Link(2, 3)) }

      it "shares 2" do
        expect(subject.shared).to eq([2])
      end

      it "not shares 1, 3" do
        expect(subject.not_shared).to match_array([1, 3])
      end
    end

    context "1-2 and 1-2" do
      subject { Link(1, 2).share_nodes(Link(2, 1)) }

      it "shares all" do
        expect(subject.shared).to match_array([1, 2])
      end

      it "not shares is empty" do
        expect(subject.not_shared).to eq([])
      end
    end
  end
end
