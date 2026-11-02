# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlacklightYul
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.log_level = :debug
    STDOUT.sync = true # turn off log buffering
    config.rails_semantic_logger.add_file_appender = false # turn off regular file appenders
    config.semantic_logger.add_appender(io: STDOUT, level: config.log_level, formatter: config.rails_semantic_logger.format)

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Set Rails default to the organization's local timezone
    config.time_zone = 'Eastern Time (US & Canada)'

    # Add gzip compression for HTML, JSON and other Rails generated responses
    config.middleware.use Rack::Deflater

    # See https://github.com/projectblacklight/blacklight/issues/2768
    config.active_record.yaml_column_permitted_classes = [HashWithIndifferentAccess]

    # Blacklight >= 7.42 appends its own config/importmap.rb, pinning its ES modules.
    # We load blacklight.js through sprockets instead, and those unused pins raise
    # AssetNotPrecompiledError from javascript_importmap_tags. This can't live in
    # config/initializers/, which loads after the importmap is already built.
    initializer "yul.skip_blacklight_importmap", after: "blacklight.importmap", before: "importmap" do |app|
      app.config.importmap.paths.delete(Blacklight::Engine.root.join("config/importmap.rb"))
    end

    # Same for blacklight-gallery >= 4.9, whose pins (masonry/slideshow) we don't use:
    # the gallery view is rendered server-side by Blacklight::Gallery::DocumentComponent.
    initializer "yul.skip_blacklight_gallery_importmap", after: "blacklight_gallery.importmap", before: "importmap" do |app|
      app.config.importmap.paths.delete(Blacklight::Gallery::Engine.root.join("config/importmap.rb"))
    end
  end
end
