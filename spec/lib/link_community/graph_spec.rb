# frozen_string_literal: true

require "mathn"
require "spec_helper"

describe Graph do
  subject do
    Graph.build do |g|
      g.add(Path(:a, :b, :c, :d, :e, :f, :c),
            Link(:d, :f))
    end
  end

  it "add link to the graph" do
    graph = Graph.build do |g|
      g.add(Link(:a, :b))
    end

    expect(graph.neighbors_node(:a)).to eq([:b])
    expect(graph.neighbors_node(:b)).to eq([:a])
  end

  it "add path to the graph" do
    graph = Graph.build do |g|
      g.add(Path(:a, :b, :c))
    end

    expect(graph.neighbors_node(:a)).to eq(%i[b])
    expect(graph.neighbors_node(:b)).to eq(%i[a c])
    expect(graph.neighbors_node(:c)).to eq(%i[b])
  end

  describe "link similarity" do
    context "no shared node" do
      it "has no similarity" do
        expect(subject.similarity_node(Link(:a, :b), Link(:c, :d))).to eq 0
      end
    end

    context "share a node" do
      it "has similarity 1/3" do
        expect(subject.similarity_node(Link(:a, :b), Link(:b, :c))).to eq(1 / 5)
        expect(subject.similarity_node(Link(:b, :c), Link(:c, :d))).to eq(1 / 6)
        expect(subject.similarity_node(Link(:c, :f), Link(:f, :d))).to eq(3 / 5)
      end
    end
  end

  describe "#links" do
    it "returns a list of links" do
      expect(subject.links_node).to match_array([Link(:a, :b),
                                                 Link(:b, :c),
                                                 Link(:c, :d),
                                                 Link(:d, :e),
                                                 Link(:e, :f),
                                                 Link(:f, :c),
                                                 Link(:d, :f)])
    end
  end

  describe "#link_community" do
    it "group the links" do
      expect(subject.link_community.groups.nodify_with(subject))
        .to eq(Group.new(5 / 6,
                         Group.new(0.80, Link(:a, :b), Link(:b, :c)),
                         Group.new(0.40,
                                   Group.new(0.00, Link(:c, :d), Link(:c, :f)),
                                   Group.new(0.25, Link(:d, :f),
                                             Group.new(0.00, Link(:d, :e), Link(:e, :f))))))
    end
  end
end
