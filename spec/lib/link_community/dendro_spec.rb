# frozen_string_literal: true

require "spec_helper"

describe Dendro do
  context "is a value object"
  describe "#==" do
    it "is same for empty dendros" do
      expect(Dendro.new).to eq(Dendro::EMPTY)
      expect(Dendro.new.hash).to eq(Dendro::EMPTY.hash)
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
      one = Dendro(1, [3, 2, 1])
      two = Dendro(1, [3, 2, Dendro(0, [1])])
      expect(one).not_to eq(two)
    end

    it "is not same discard dendros" do
      one = Dendro(1, [3, 2]) # element "1" removed
      two = Dendro(1, [3, 2, Dendro(0, [1])])
      expect(one).not_to eq(two)
    end

    it "is same even nested" do
      one = Dendro(1, [3,
                       Dendro(0, [2, 1]),
                       Dendro(0, [4])])

      two = Dendro(1, [Dendro(0, [2, 1]),
                       3,
                       Dendro(0, [4])])

      expect(one).to eq(two)
      expect(one.hash).to eq(two.hash)
    end

    it "is not same if difference is nested" do
      one = Dendro(1, [3,
                       Dendro(0, [2, 1]),
                       Dendro(0, [4])])

      two = Dendro(1, [Dendro(0, [2, 3]), # previous "1" is now "3"
                       3,
                       Dendro(0, [4])])

      expect(one).not_to eq(two)
    end
  end

  describe "#push" do
    context "to same level" do
      it "adds to the member list" do
        head = Dendro(1, [1, 2])
        head.push(Dendro(1, [3]))
        expect(head).to eq(Dendro(1, [1, 2, 3]))
      end
    end

    context "from lower level" do
      it "adds to a children" do
        head = Dendro(2, [1, 2])
        head.push(Dendro(1, [3]))
        expect(head).to eq(Dendro(2, [1,
                                      2,
                                      Dendro(1, 3)]))
      end
    end
  end

  describe "#push" do
    context "to same level" do
      it "adds to the member list" do
        head = Dendro(1, [1, 2])

        builder = DendroBuilder.new(head)
        builder.push(1, 2, 3)

        expect(builder.rslt).to eq(Dendro(1, [1, 2, 3]))
      end
    end

    context "from lower level" do
      it "adds to a children" do
        head = Dendro(2, [1, 2])

        builder = DendroBuilder.new(head)
        builder.push(1, 2, 3)

        expect(builder.rslt).to eq(Dendro(2, [1,
                                              Dendro(1, [2, 3])]))
      end

      it "adds to a subdendro" do
        head = Dendro(3, [1, 2,
                          Dendro(2, [3, 4,
                                     Dendro(1, [5, 6])])])

        builder = DendroBuilder.new(head)
        builder.push(1, 6, 7)

        expect(builder.rslt).to eq(Dendro(3, [1, 2,
                                              Dendro(2, [3, 4,
                                                         Dendro(1, [5, 6, 7])])]))
      end
    end
  end

  describe "#map" do
    subject { Dendro(2, [1, Dendro(1, [3, 4]), Dendro(1, [6, 7])]) }

    it "creates a simple copy" do
      copy = subject.map { |e| e }
      expect(copy).to eq(subject)
    end

    it "creates a modified copy" do
      times2 = subject.map { |e| e * 2 }
      expect(times2).to eq(Dendro(2, [2, Dendro(1, [6, 8]), Dendro(1, [12, 14])]))
    end
  end
end
