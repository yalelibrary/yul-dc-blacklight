# frozen_string_literal: true
require 'rails_helper'
require 'net/http'

# Hits live external sites, so it is excluded from the default run. Run it with:
#   bundle exec rspec --tag external_links
RSpec.describe 'Live header and footer links', :external_links do
  header_urls = YAML.load_file(Rails.root.join('config', 'locales', 'submenu.en.yml'))
                    .dig('en', 'submenu').values.flat_map(&:values).map { |link| link['url'].strip }

  footer_urls = [
    'https://ask.library.yale.edu/',
    'https://library.yale.edu/my-library-accounts',
    'https://library.yale.edu/accessibility',
    'https://library.yale.edu/giving',
    'https://library.yale.edu/about-us/about/library-policies/privacy-and-data-use'
  ]

  before(:all) { WebMock.allow_net_connect! }
  after(:all)  { WebMock.disable_net_connect!(allow: WEBMOCK_ALLOWED_SITES) }

  (header_urls + footer_urls).uniq.each do |url|
    it "#{url} is up" do
      response = Net::HTTP.get_response(URI(url))
      # Redirects count as up; many older links redirect to the new library site.
      expect(response.code.to_i).to be < 400
    end
  end
end
