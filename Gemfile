# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '~> 3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
# Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/] (https://github.com/ged/ruby-pg)
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Integrate SassC-Ruby with Rails!
# gem 'sassc-rails', '~> 2.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.8', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# DSL for declaring params and options of the initializer (https://dry-rb.org/gems/dry-initializer)
# gem 'dry-initializer-rails'
# Easily generate fake data (https://github.com/faker-ruby/faker)
# gem "faker", "~> 2.16" # Used in db/seeds.rb
# RSpec for Rails (https://github.com/rspec/rspec-rails)
gem 'rspec-rails'
# Performance testing matchers for RSpec (https://github.com/piotrmurach/rspec-benchmark)
gem 'rspec-benchmark'
# ActiveModel validation for email. Including MX lookup and disposable email blacklist (https://github.com/micke/valid_email2)
gem 'valid_email2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Use Pry as your rails console (https://github.com/rweng/pry-rails)
  gem 'pry-rails'
  # Walk the stack in a Pry session (https://github.com/pry/pry-stack_explorer)
  gem 'pry-stack_explorer'
  # Fast debugging with Pry. (https://github.com/deivid-rodriguez/pry-byebug)
  gem 'pry-byebug'
end

group :profiling do
  # A sampling call-stack profiler for ruby 2.2+ (http://github.com/tmm1/stackprof)
  gem 'stackprof'
  # Fast Ruby profiler (https://github.com/ruby-prof/ruby-prof)
  gem 'ruby-prof' #  Tracing memory profiler. Better on production/staging!
end

group :development do
  # Listen to file modifications (https://github.com/guard/listen)
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # A debugging tool for your Ruby on Rails applications. (https://github.com/rails/web-console)
  gem 'web-console'
end

group :test do
  # Strategies for cleaning databases using ActiveRecord. Can be used to ensure a clean state for testing. (https://github.com/DatabaseCleaner/database_cleaner-active_record)
  gem 'database_cleaner-active_record'
  # Monitor your Ruby Applications metrics via your test suite. (https://github.com/PigCI/pig-ci-rails)
  gem 'pig-ci-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
