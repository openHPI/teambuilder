# frozen_string_literal: true

source 'https://rubygems.org'
ruby '~> 2.7.0'

# Rails
gem 'rails', '~> 5.2.0'
gem 'puma', '~> 6.0'
gem 'pg'
gem 'slim-rails'
gem 'config'
gem 'workflow', '~> 1.2'
gem 'sidekiq', '~> 7.0'

# Auth
gem 'warden'
gem 'rails_warden'

# Grouping
gem 'dbscan'
gem 'forgery'
gem 'geocoder'
gem 'geokit-rails'

# Assets
gem 'sass-rails', '~> 5.0'
gem 'neat', '~> 1.0'
gem 'bourbon', '~> 4.0'
gem 'uglifier', '>= 1.3.0'

# Service / LTI communication
gem 'restify'
gem 'rack-p3p'
gem 'ims-lti', '~> 2.0'
gem 'oauth', '~> 0.6.0'
gem 'builder'

# Monitoring
gem 'mnemosyne-ruby', '~> 2.0'

gem 'bootsnap', require: false

# Debugging / testing helpers
group :development do
  gem 'listen', '>= 3.0.5', '< 3.8.1'
  gem 'spring'
end

group :development, :test do
  gem 'capybara'
  gem 'pry-byebug'
  gem 'rspec'
  gem 'rspec-rails', '~> 5.0'
  gem 'warden-rspec-rails', git: 'https://github.com/ajsharp/warden-rspec-rails.git'
end

group :test do
  # https://github.com/thoughtbot/factory_bot_rails/pull/432
  gem 'factory_bot_rails', '~> 6.0'
  gem 'rails-controller-testing'
end
