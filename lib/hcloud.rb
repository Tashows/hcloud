# frozen_string_literal: true

require "active_model"
require "active_support/all"
require "zeitwerk"

module HCloud
  class << self
    # Code loader instance
    attr_reader :loader

    def root
      @root ||= Pathname.new(File.expand_path(File.join("..", ".."), __FILE__))
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def setup
      @loader = Zeitwerk::Loader.for_gem

      # Register inflections
      require root.join("config/inflections.rb")

      # Collapse resources
      loader.collapse(
        root.join("lib/hcloud/entities"),
        root.join("lib/hcloud/concerns"),
        root.join("lib/hcloud/resources"),
        root.join("lib/hcloud/types"),
      )

      # Load types
      Dir[root.join("lib/hcloud/types/*.rb")].sort.each { |f| require f }

      loader.setup
      loader.eager_load
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end

HCloud.setup
