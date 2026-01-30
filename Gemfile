# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'addressable', '~> 2.8.6'
gem 'awesome_print', '~> 1.9.2'
gem "aws-sdk-cloudwatch", '~> 1.84.0'
gem 'aws-sdk-s3', '~> 1.208.0'
gem 'blacklight', '~> 7.36.2'
gem "blacklight_advanced_search", '~> 7.0.0'
gem 'blacklight_dynamic_sitemap', '~> 1.0.0'
gem 'blacklight-gallery', '~> 4.0.2'
gem 'blacklight_iiif_search', git: 'https://github.com/yalelibrary/blacklight_iiif_search', branch: 'main'
gem 'blacklight-marc', '>= 7.0.0.rc1', '< 8'
gem 'blacklight_oai_provider', git: 'https://github.com/projectblacklight/blacklight_oai_provider.git'
gem 'blacklight_range_limit', '~> 8.5.0'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bootstrap', '~> 5.3'
gem 'citeproc-ruby', '~> 2.0.0'
# pinned due to https://github.com/rails/rails/pull/54264
gem 'concurrent-ruby', '< 1.3.5'
gem 'csl-styles', '~> 2.0.1'
gem 'devise', '~> 4.9.3'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails', '~> 2.8.1', groups: [:development, :test]
gem 'honeybadger', '~> 4.0'
gem 'iso-639', '~> 0.3.6'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails', '~> 4.6.0'
gem 'logger', '~> 1.6.0'
gem 'omniauth', '~> 2.1.0'
gem 'omniauth_openid_connect', '~> 0.7.1'
gem 'openseadragon', '~> 0.6.0'
# This addresses CVE-2015-9284 https://github.com/advisories/GHSA-ww4x-rwq6-qpgf
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'partridge', '~> 0.1.2'
gem 'pg', '~> 1.5.4'
gem 'puma', '~> 5.6'
# pinned to before 4 due to https://stackoverflow.com/questions/71191685/visit-psych-nodes-alias-unknown-alias-default-psychbadalias
gem 'psych', '< 4'
gem 'rails', '~> 7.0.8'
gem "rails_semantic_logger", ">=4.4.4"
gem 'rsolr', '>= 1.0', '< 3'
gem 'sass-rails', '>= 6'
gem 'sprockets-rails', '~> 3.4.2'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'unicode-display_width', '~> 2.5'
gem 'webpacker', '~> 5.0'
gem 'yard', '~> 0.9.36'

group :development, :test do
  gem 'bixby', '~> 5.0.1'
  gem 'byebug', '~> 11.1.3', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 5.0.0'
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  gem 'activerecord-nulldb-adapter', '~> 1.0.1'
  gem "amazing_print", ">=1.2.1"
  gem 'listen', '~> 3.2'
  gem 'spring', '~> 4.1'
  gem 'spring-watcher-listen', '~> 2.1.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'apparition', '~> 0.6.0'
  gem 'axe-matchers', '~> 2.6.1'
  gem 'capybara', '>= 2.15'
  gem 'coveralls_reborn', '~> 0.28.0', require: false
  gem 'factory_bot_rails', '~> 6.4.3'
  gem 'ffaker', '2.20.0'
  gem 'rails-controller-testing', '~> 1.0.5'
  gem 'selenium-webdriver', '~> 4.16'
  gem 'webdrivers', '~> 5.2.0', require: false
  gem 'webmock', '~> 3.19.1'
end
