# frozen_string_literal: true

module LinkCommunity
  class GraphBuilder
    def initialize(links = [])
      @links = links
    end

    def build
      Graph.new(@links)
    end

    def add(*links)
      links.each { |link| link.add_itself_to(self) }
      self
    end

    def add_link(a, b)
      @links << [a, b]
    end
  end
end
