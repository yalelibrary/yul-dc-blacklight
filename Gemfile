# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

gem 'awesome_print'
gem 'aws-sdk-s3'
gem 'blacklight', '>= 7.0'
gem 'blacklight-gallery'
gem 'blacklight-marc', '>= 7.0.0.rc1', '< 8'
gem "blacklight_advanced_search"
gem 'blacklight_dynamic_sitemap'
gem 'blacklight_iiif_search'
gem 'blacklight_oai_provider', git: 'https://github.com/projectblacklight/blacklight_oai_provider.git'
gem 'blacklight_range_limit'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bootstrap', '~> 4.0'
gem 'citeproc-ruby'
gem 'csl-styles'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails', groups: [:development, :test]
gem 'honeybadger', '~> 4.0'
gem 'iso-639'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails'
gem 'omniauth'
gem 'omniauth-cas'
# This addresses CVE-2015-9284 https://github.com/advisories/GHSA-ww4x-rwq6-qpgf
gem 'omniauth-rails_csrf_protection', '~> 0.1'
gem 'partridge', '~> 0.1.2'
gem 'pg'
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0.3.7'
gem "rails_semantic_logger", ">=4.4.4"
gem 'rsolr', '>= 1.0', '< 3'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'webpacker', '~> 4.0'
gem 'yard'

group :development, :test do
  gem 'bixby', '~> 3.0.0'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 4.0.0'
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  gem 'activerecord-nulldb-adapter'
  gem "amazing_print", ">=1.2.1"
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'apparition'
  gem 'axe-matchers'
  gem 'capybara', '>= 2.15'
  gem 'coveralls', require: false
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'webmock'
end
