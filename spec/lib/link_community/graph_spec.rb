# frozen_string_literal: true

require "mathn"
require "spec_helper"

describe Graph do
  context "directed weighted" do
    subject do
      Graph.build do |g|
        g.add(DLink(:a, :b, 2),
              DLink(:b, :c, 2),
              DLink(:c, :d, 3),
              DLink(:d, :e, 4),
              DLink(:e, :f, 4),
              DLink(:f, :c, 3),
              DLink(:d, :f, 4),
              DLink(:a, :g, 2),
              DLink(:b, :g, 2))
      end
    end

    it "add link to the graph" do
      graph = Graph.build do |g|
        g.add(DLink(:a, :b, 1))
      end

      expect(graph.neighbors_node(:a)).to eq([:b])
      expect(graph.neighbors_node(:b)).to eq([])
    end

    describe "#links" do
      it "returns a list of links" do
        expect(subject.links_node).to match_array([DLink(:a, :b, 2),
                                                   DLink(:b, :c, 2),
                                                   DLink(:c, :d, 3),
                                                   DLink(:d, :e, 4),
                                                   DLink(:e, :f, 4),
                                                   DLink(:f, :c, 3),
                                                   DLink(:d, :f, 4),
                                                   DLink(:a, :g, 2),
                                                   DLink(:b, :g, 2)])
      end
    end

    describe "link similarity" do
      context "no shared node" do
        it "has no similarity" do
          expect(subject.similarity_node(Link(:a, :b), Link(:c, :d))).to eq 0
        end
      end

      context "share a node" do
        it "has similarity " do
          expect(subject.similarity_node(Link(:a, :g), Link(:b, :g))).to eq(0.5)
          expect(subject.similarity_node(Link(:a, :b), Link(:a, :g))).to eq(0)
          expect(subject.similarity_node(Link(:a, :b), Link(:b, :g))).to eq(0)
        end
      end
    end

    it "group the links" do
      expect(subject.link_community.dendrogram.map { |link| link.nodify_with(subject) })
        .to eq(Dendro(1, [
                        DLink(:a, :b, 2),
                        Dendro(0.78, [
                                 Dendro(0.75, [
                                          DLink(:b, :c, 2),
                                          DLink(:f, :c, 3)
                                        ]),
                                 Dendro(0.68, [
                                          DLink(:d, :e, 4),
                                          Dendro(0.67, [
                                                   DLink(:c, :d, 3),
                                                   Dendro(0.33, [
                                                            DLink(:d, :f, 4),
                                                            DLink(:e, :f, 4)
                                                          ])
                                                 ])
                                        ])
                               ]),
                        Dendro(0.5, [
                                 DLink(:a, :g, 2),
                                 DLink(:b, :g, 2)
                               ])
                      ]))
    end

    context "with mutual connection" do
      subject do
        Graph.build do |g|
          g.add(DLink(:a, :b, 99999),
                DLink(:b, :a, 1))
        end
      end

      it "should be 1" do
        expect(subject.similarity_node(Link(:a, :b), Link(:b, :a))).to eq(1)
      end
    end

    context "coming to the same vertex (and same weight)" do
      subject do
        Graph.build do |g|
          g.add(DLink(:a, :b, 2),
                DLink(:c, :b, 2))
        end
      end

      it "should be 1/3" do
        expect(subject.similarity_node(Link(:a, :b), Link(:c, :b))).to eq(1 / 3)
      end
    end

    context "coming to two vertices (twice)" do
      subject do
        Graph.build do |g|
          g.add(DLink(:a, :b, 2),
                DLink(:c, :b, 2),
                DLink(:a, :d, 2),
                DLink(:c, :d, 2))
        end
      end

      it "should be 1/2 (as they share 2 distinct nodes)" do
        expect(subject.similarity_node(Link(:a, :b), Link(:c, :b))).to eq(1 / 2)
        expect(subject.similarity_node(Link(:a, :d), Link(:c, :d))).to eq(1 / 2)
      end
    end

    context "leaving the same vertex (and same weight)" do
      subject do
        Graph.build do |g|
          g.add(DLink(:b, :a, 2),
                DLink(:b, :c, 2))
        end
      end

      it "should be 0 (they don't share any vertex)" do
        expect(subject.similarity_node(Link(:b, :a), Link(:b, :c))).to eq(0)
      end
    end

    context "leaving the same vertex and one extra connection (a)<-(b)->(c)->(a)" do
      subject do
        Graph.build do |g|
          g.add(DLink(:b, :a, 2),
                DLink(:b, :c, 2),
                DLink(:c, :a, 2))
        end
      end

      it "should be 0 (one link is not enough)" do
        expect(subject.similarity_node(Link(:b, :a), Link(:b, :c))).to eq(0)
      end
    end

    context "leaving the same vertex with cycle" do
      subject do
        Graph.build do |g|
          g.add(DLink(:b, :a, 2),
                DLink(:b, :c, 2),
                DLink(:a, :c, 2),
                DLink(:c, :a, 2))
        end
      end

      it "should be 1 (they share the same vertex with same weight)" do
        expect(subject.similarity_node(Link(:b, :a), Link(:b, :c))).to eq(1)
      end
    end

    context "leaving the same vertex with extra node" do
      subject do
        Graph.build do |g|
          g.add(DLink(:b, :a, 2),
                DLink(:b, :c, 2),
                DLink(:a, :d, 2),
                DLink(:c, :d, 2))
        end
      end

      it "should be 1/3 (they share a single vertex)" do
        expect(subject.similarity_node(Link(:b, :a), Link(:b, :c))).to eq(1 / 3)
      end
    end

    context "(a)->(c)<-(b), (a)->(d)<-(b), (a)->(b), (c)->(d)" do
      subject do
        Graph.build do |g|
          g.add(DLink(:a, :c, 2),
                DLink(:a, :d, 2),
                DLink(:b, :c, 2),
                DLink(:b, :d, 2),
                DLink(:a, :b, 2),
                DLink(:c, :d, 2))
        end
      end

      it "is fairly connected!" do
        expect(subject.similarity_node(Link(:a, :c), Link(:b, :c))).to eq(3 / 4)
        expect(subject.similarity_node(Link(:a, :d), Link(:b, :d))).to eq(3 / 4)
        expect(subject.similarity_node(Link(:a, :c), Link(:a, :d))).to eq(0)
        expect(subject.similarity_node(Link(:b, :c), Link(:b, :d))).to eq(0)
        expect(subject.similarity_node(Link(:c, :d), Link(:b, :d))).to eq(2 / 3)
        expect(subject.similarity_node(Link(:a, :c), Link(:a, :b))).to eq(2 / 3)
      end

      describe "#dendrogram" do
        it "detect community and creates the dendrogram" do
          expect(subject.dendrogram)
            .to eq(Dendro(1.00, [
                            Dendro(0.33, [
                                     DLink(:c, :d, 2),
                                     Dendro(0.25, [
                                              DLink(:a, :d, 2),
                                              DLink(:b, :d, 2)
                                            ])
                                   ]),
                            Dendro(0.33, [
                                     DLink(:a, :b, 2),
                                     Dendro(0.25, [
                                              DLink(:a, :c, 2),
                                              DLink(:b, :c, 2)
                                            ])
                                   ])
                          ]))
        end
      end
    end
  end

  context "directed" do
    subject do
      Graph.build do |g|
        g.add(DLink(:a, :b),
              DLink(:b, :c),
              DLink(:c, :d),
              DLink(:d, :e),
              DLink(:e, :f),
              DLink(:f, :c),
              DLink(:d, :f),
              DLink(:a, :g),
              DLink(:b, :g))
      end
    end

    it "add link to the graph" do
      graph = Graph.build do |g|
        g.add(DLink(:a, :b))
      end

      expect(graph.neighbors_node(:a)).to eq([:b])
      expect(graph.neighbors_node(:b)).to eq([])
    end

    describe "#links" do
      it "returns a list of links" do
        expect(subject.links_node).to match_array([DLink(:a, :b),
                                                   DLink(:b, :c),
                                                   DLink(:c, :d),
                                                   DLink(:d, :e),
                                                   DLink(:e, :f),
                                                   DLink(:f, :c),
                                                   DLink(:d, :f),
                                                   DLink(:a, :g),
                                                   DLink(:b, :g)])
      end
    end
    describe "link similarity" do
      context "no shared node" do
        it "has no similarity" do
          expect(subject.similarity_node(Link(:a, :b), Link(:c, :d))).to eq 0
        end
      end

      context "share a node" do
        it "has similarity " do
          expect(subject.similarity_node(Link(:a, :g), Link(:b, :g))).to eq(0.5)
          expect(subject.similarity_node(Link(:a, :b), Link(:a, :g))).to eq(1 / 3)
          expect(subject.similarity_node(Link(:a, :b), Link(:b, :g))).to eq(1 / 3)
        end
      end
    end
  end

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
