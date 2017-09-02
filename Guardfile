# frozen_string_literal: true

group :tdd, halt_on_fail: true do
  guard :rspec, cmd: "bundle exec rspec", all_after_pass: true do
    require "guard/rspec/dsl"
    dsl = Guard::RSpec::Dsl.new(self)

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)
    watch("spec/spec_helper.rb") { spec }
    watch("lib/*.rb") { spec }

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)
  end
  guard :rubocop, cmd: "bundle exec rubocop", cli: "-fs -c./.rubocop.yml" do
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end
