# frozen_string_literal: true

namespace :yale do
  # Build code documentation for this project
  namespace :docs do
    YARD::Rake::YardocTask.new do |t|
      t.name = "blacklight"
      t.files = ['app/**/*.rb']
    end
  end
end
