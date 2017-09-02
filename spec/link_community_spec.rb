# frozen_string_literal: true

require "spec_helper"
include LinkCommunity

RSpec.describe LinkCommunity do
  it "has a version number" do
    expect(LinkCommunity::VERSION).not_to be nil
  end
end
