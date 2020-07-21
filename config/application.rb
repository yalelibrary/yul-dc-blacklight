# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlacklightYul
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.log_level = :debug
    STDOUT.sync = true # turn off log buffering
    config.rails_semantic_logger.add_file_appender = false # turn off regular file appenders
    config.semantic_logger.add_appender(io: STDOUT, level: config.log_level, formatter: :json)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Rails default to the organization's local timezone
    config.time_zone = 'Eastern Time (US & Canada)'
  end
end
