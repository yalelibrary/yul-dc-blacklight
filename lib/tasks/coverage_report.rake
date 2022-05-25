# frozen_string_literal: true

require 'simplecov_json_formatter'

namespace :coverage do
  task report: :environment do
    require 'simplecov'

    SimpleCov.collate Dir["coverage_results/.resultset-*.json"], 'rails' do
      formatter SimpleCov::Formatter::MultiFormatter.new(
        [
          SimpleCov::Formatter::JSONFormatter,
          SimpleCov::Formatter::HTMLFormatter
        ]
      )
    end
  end
end
