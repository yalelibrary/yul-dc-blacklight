# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'addressable'
gem 'awesome_print'
gem "aws-sdk-cloudwatch"
gem 'aws-sdk-s3'
gem 'blacklight', '~> 7.36.2'
gem "blacklight_advanced_search"
gem 'blacklight_dynamic_sitemap'
gem 'blacklight-gallery', '~> 4.0.2'
gem 'blacklight_iiif_search', git: 'https://github.com/yalelibrary/blacklight_iiif_search', branch: 'main'
gem 'blacklight-marc', '>= 7.0.0.rc1', '< 8'
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
gem 'omniauth', '~> 2.1.0'
gem 'omniauth_openid_connect'
# This addresses CVE-2015-9284 https://github.com/advisories/GHSA-ww4x-rwq6-qpgf
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'openseadragon'
gem 'partridge', '~> 0.1.2'
gem 'pg'
gem 'puma', '~> 5.6'
# pinned to before 4 due to https://stackoverflow.com/questions/71191685/visit-psych-nodes-alias-unknown-alias-default-psychbadalias
gem 'psych', '< 4'
gem 'rails', '~> 7.0.8'
gem "rails_semantic_logger", ">=4.4.4"
gem 'rsolr', '>= 1.0', '< 3'
gem 'sass-rails', '>= 6'
gem 'sprockets-rails'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'unicode-display_width', '~> 2.5'
gem 'webpacker', '~> 4.0'
gem 'yard'

group :development, :test do
  gem 'bixby', '~> 5.0.1'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 5.0.0'
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  gem 'activerecord-nulldb-adapter'
  gem "amazing_print", ">=1.2.1"
  gem 'listen', '~> 3.2'
  gem 'spring', '~> 4.1'
  gem 'spring-watcher-listen'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'apparition'
  gem 'axe-matchers'
  gem 'capybara', '>= 2.15'
  gem 'coveralls_reborn', require: false
  gem 'factory_bot_rails'
  gem 'ffaker', '2.20.0'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver', '~> 4.16'
  gem 'webdrivers', require: false
  gem 'webmock'
end
