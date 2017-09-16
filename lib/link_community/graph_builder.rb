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

    def add_link(from, to_reference)
      @links << [from, to_reference]
    end
  end
end
