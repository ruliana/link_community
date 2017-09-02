# frozen_string_literal: true

require "mathn"
require "spec_helper"

describe Graph do
  it "add link to the graph" do
    graph = Graph.new
    graph.add(Link(:a, :b))
    expect(graph.neighbors(:a)).to eq(Set(:b))
    expect(graph.neighbors(:b)).to eq(Set(:a))
  end

  it "add path to the graph" do
    graph = Graph.new
    graph.add(Path(:a, :b, :c))

    expect(graph.neighbors(:a)).to eq(Set(:b))
    expect(graph.neighbors(:b)).to eq(Set(:a, :c))
    expect(graph.neighbors(:c)).to eq(Set(:b))
  end

  describe "link similarity" do
    subject do
      graph = Graph.new
      graph.add(Path(:a, :b, :c, :d, :e, :f, :c),
                Link(:d, :f))
    end

    context "no shared node" do
      it "has no similarity" do
        expect(subject.similarity(Link(:a, :b), Link(:c, :d))).to eq 0
      end
    end

    context "share a node" do
      it "has similarity 1/3" do
        expect(subject.similarity(Link(:a, :b), Link(:b, :c))).to eq(1 / 5)
        expect(subject.similarity(Link(:b, :c), Link(:c, :d))).to eq(1 / 6)
        expect(subject.similarity(Link(:c, :f), Link(:f, :d))).to eq(3 / 5)
      end
    end
  end
end