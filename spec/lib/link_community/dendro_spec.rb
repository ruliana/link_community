# frozen_string_literal: true

require "spec_helper"

describe Dendro do
  context "is a value object"
  describe "#==" do
    it "is same for empty dendros" do
      expect(Dendro.new).to eq(Dendro.new)
      expect(Dendro.new.hash).to eq(Dendro.new.hash)
    end

    it "is same no matter the order" do
      one = Dendro.new(1, 2, 3)
      two = Dendro.new(3, 2, 1)
      expect(one).to eq(two)
      expect(one.hash).to eq(two.hash)
    end

    it "is same no matter the order" do
      one = Dendro.new(1, 2, 3)
      two = Dendro.new(3, 2, 1)
      expect(one).to eq(two)
      expect(one.hash).to eq(two.hash)
    end

    it "is not same if mix dendros" do
      one = Dendro.new(3, 2, 1)
      two = Dendro.new(3, 2, Dendro.new(1, level: 0))
      expect(one).not_to eq(two)
    end

    it "is not same discard dendros" do
      one = Dendro.new(3, 2)
      two = Dendro.new(3, 2, Dendro.new(1, level: 0))
      expect(one).not_to eq(two)
    end

    it "is same even nested" do
      one = Dendro.new(3,
                       Dendro.new(2, 1, level: 0),
                       Dendro.new(4, level: 0))
      two = Dendro.new(Dendro.new(2, 1, level: 0),
                       3,
                       Dendro.new(4, level: 0))
      expect(one).to eq(two)
      expect(one.hash).to eq(two.hash)
    end

    it "is not same if difference is nested" do
      one = Dendro.new(3,
                       Dendro.new(2, 1, level: 0),
                       Dendro.new(4, level: 0))
      two = Dendro.new(Dendro.new(2, 3, level: 0),
                       3,
                       Dendro.new(4, level: 0))
      expect(one).not_to eq(two)
    end
  end

  describe "#push" do
    context "to same level" do
      it "adds to the member list" do
        head = Dendro.new(1, 2, level: 1)
        head.push(Dendro.new(3, level: 1))
        expect(head).to eq(Dendro.new(1, 2, 3, level: 1))
      end
    end

    context "from lower level" do
      it "adds to a children" do
        head = Dendro.new(1, 2, level: 2)
        head.push(Dendro.new(3, level: 1))
        expect(head).to eq(Dendro.new(1, 2,
                                      Dendro.new(3, level: 1),
                                      level: 2))
      end
    end
  end

  describe "#push_pack" do
    context "to same level" do
      it "adds to the member list" do
        head = Dendro.new(1, 2, level: 1)

        builder = DendroBuilder.new(head)
        builder.push([1, 2, 3])

        expect(builder.rslt).to eq(Dendro.new(1, 2, 3, level: 1))
      end
    end

    context "from lower level" do
      it "adds to a children" do
        head = Dendro.new(1, 2, level: 2)

        builder = DendroBuilder.new(head)
        builder.push([1, 2, 3])

        expect(builder.rslt).to eq(Dendro.new(1,
                                              Dendro.new(2, 3, level: 1),
                                              level: 2))
      end

      it "adds to a subdendro" do
        head = Dendro.new(1, 2,
                          Dendro.new(3, 4,
                                     Dendro.new(5, 6, level: 1),
                                     level: 2),
                          level: 3)

        builder = DendroBuilder.new(head)
        builder.push([1, 6, 7])

        expect(builder.rslt).to eq(Dendro.new(1, 2,
                                              Dendro.new(3, 4,
                                                         Dendro.new(5, 6, 7, level: 1),
                                                         level: 2),
                                              level: 3))

      end
    end
  end
end
