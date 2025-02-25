# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.8', '>= 7.0.8.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use mysql2 as the database for Active Record
gem 'mysql2'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Gems globales
gem 'browser'
gem 'byebug'
gem 'capybara'
gem 'devise'
gem 'httparty'
gem 'nokogiri'
gem 'selenium-webdriver'
gem 'sidekiq'

group :development, :test do
    gem 'debug', platforms: %i[mri mingw x64_mingw]
    gem 'factory_bot_rails'
    gem 'faker'
    gem 'rspec-rails'
end

group :development do
    gem 'web-console'
    gem 'rubocop', require: false
    gem 'rubocop-capybara', require: false
    gem 'rubocop-performance', require: false
    gem 'rubocop-rails', require: false
    gem 'rubocop-rspec', require: false
end

group :test do
    gem 'database_cleaner-active_record'
    gem 'shoulda-matchers'
    gem 'simplecov', require: false
    gem 'webdrivers'
end