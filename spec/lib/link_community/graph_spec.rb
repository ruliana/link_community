# frozen_string_literal: true

require "mathn"
require "spec_helper"

describe Graph do
  context "weighted" do
    subject do
      Graph.build do |g|
        g.add(Link(:a, :b, 2),
              Link(:b, :c, 2),
              Link(:c, :d, 3),
              Link(:d, :e, 4),
              Link(:e, :f, 4),
              Link(:f, :c, 3),
              Link(:d, :f, 4),
              Link(:a, :g, 2),
              Link(:b, :g, 2))
      end
    end

    it "add link to the graph" do
      require "byebug"
      graph = Graph.build do |g|
        g.add(Link(:a, :b, 1))
      end

      expect(graph.neighbors_node(:a)).to eq([:b])
      expect(graph.neighbors_node(:b)).to eq([:a])
    end

    describe "#links" do
      it "returns a list of links" do
        expect(subject.links_node).to match_array([Link(:a, :b, 2),
                                                   Link(:b, :c, 2),
                                                   Link(:c, :d, 3),
                                                   Link(:d, :e, 4),
                                                   Link(:e, :f, 4),
                                                   Link(:f, :c, 3),
                                                   Link(:d, :f, 4),
                                                   Link(:a, :g, 2),
                                                   Link(:b, :g, 2)])
      end
    end

    describe "link similarity" do
      context "no shared node" do
        it "has no similarity" do
          expect(subject.similarity_node(Link(:a, :b, 1), Link(:c, :d, 3))).to eq 0
        end
      end

      context "edges (c)-(d) and (c)-(f)" do
        it "has similarity near 99.5" do
          cd = Link(:c, :d, 3)
          cf = Link(:c, :f, 3)
          expect(subject.similarity_node(cd, cf)).to be_within(0.0001).of(0.996)
        end
      end

      context "edges (e)-(d) and (e)-(f)" do
        it "has similarity near 99.5" do
          ed = Link(:e, :d, 3)
          ef = Link(:e, :f, 3)
          expect(subject.similarity_node(ed, ef)).to be_within(0.001).of(0.996)
        end
      end

      context "edges (c)-(b) and (c)-(d)" do
        it "has similarity near 99.5" do
          ed = Link(:c, :b, 2)
          ef = Link(:c, :d, 3)
          expect(subject.similarity_node(ed, ef).to_f).to be_within(0.001).of(0.093)
        end
      end

      context "edges (a)-(b)-(g)-(a)" do
        it "(a)-(g) and (a)-(b) has similarity 3/4" do
          expect(subject.similarity_node(Link(:a, :b, 2), Link(:a, :g, 2))).to eq(3 / 4)
          expect(subject.similarity_node(Link(:g, :b, 2), Link(:a, :g, 2))).to eq(3 / 4)
        end

        it "(g)-(a) and (g) has similarity 1" do
          expect(subject.similarity_node(Link(:b, :a, 2), Link(:b, :g, 2))).to eq(1)
        end
      end
    end
  end

  context "simple" do
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
        expect(subject.link_community.dendrogram.map { |link| link.nodify_with(subject) })
          .to eq(Dendro(5 / 6, [
                          Dendro(0.80, [Link(:a, :b), Link(:b, :c)]),
                          Dendro(0.40, [
                                   Dendro(0.00, [Link(:c, :d), Link(:c, :f)]),
                                   Dendro(0.25, [
                                            Link(:d, :f),
                                            Dendro(0.00, [Link(:d, :e), Link(:e, :f)])
                                          ])
                                 ])
                        ]))
      end
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
  end
end
