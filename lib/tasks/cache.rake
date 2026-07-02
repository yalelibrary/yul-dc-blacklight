# frozen_string_literal: true

namespace :cache do
  desc "Clear the Rails cache"
  task clear: :environment do
    Rails.cache.clear
    Rails.logger.info("Rails cache cleared")
  end
end
