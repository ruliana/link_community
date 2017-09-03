# frozen_string_literal: true

require "set"

module LinkCommunity
  EMPTY_SET = Set.new.freeze

  # Function constructor for immutable Set
  def Set(*elements)
    Set.new(elements).freeze
  end
end

require "link_community/version"
require "link_community/link"
require "link_community/path"
require "link_community/graph"

require "link_community/algorithms/slink"
