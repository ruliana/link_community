# frozen_string_literal: true

require "set"

module LinkCommunity
  EMPTY_SET = Set.new.freeze

  # Function constructor for immutable Set
  def Set(*elements)
    Set.new(elements).freeze
  end

  # Functional constructor for weighted and
  # unweighted links.
  def Link(from, to, weight = nil)
    if weight
      WeightedLink.new(from, to, weight)
    else
      Link.new(from, to)
    end
  end

  def DLink(from, to, weight = nil)
    if weight
      DirectedWeightedLink.new(from, to, weight)
    else
      DirectedLink.new(from, to)
    end
  end
end

# Necessary to load functional constructors
include LinkCommunity

# Extra methods (utilities)
require "link_community/refinements/array"

# Core entities
require "link_community/version"
require "link_community/unweighted_partial_link"
require "link_community/weighted_partial_link"
require "link_community/link"
require "link_community/weighted_link"
require "link_community/directed_link"
require "link_community/directed_weighted_link"
require "link_community/path"
require "link_community/graph"
require "link_community/graph_builder"
require "link_community/dendro"

# Algorithms
require "link_community/algorithms/slink"

# Utilities
require "link_community/csv_to_graph"
require "link_community/extra/console_monitor"
