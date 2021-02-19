source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.1'
# Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/] (https://github.com/ged/ruby-pg)
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# A complete suite of testing facilities supporting TDD, BDD, mocking, and benchmarking (https://github.com/seattlerb/minitest)
# gem 'minitest'
# RSpec for Rails (https://github.com/rspec/rspec-rails)
gem 'rspec-rails'
# Performance testing matchers for RSpec (https://github.com/piotrmurach/rspec-benchmark)
gem 'rspec-benchmark'
# Fast Ruby profiler (https://github.com/ruby-prof/ruby-prof)
gem 'ruby-prof'
# A sampling call-stack profiler for ruby 2.2+ (http://github.com/tmm1/stackprof)
gem 'stackprof'
# ActiveModel validation for email. Including MX lookup and disposable email blacklist (https://github.com/micke/valid_email2)
gem 'valid_email2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Listen to file modifications (https://github.com/guard/listen)
  gem 'listen', '~> 3.3'
  # Use Pry as your rails console (https://github.com/rweng/pry-rails)
  gem 'pry-rails'
  # Walk the stack in a Pry session (https://github.com/pry/pry-stack_explorer)
  gem 'pry-stack_explorer'
  # Fast debugging with Pry. (https://github.com/deivid-rodriguez/pry-byebug)
  gem 'pry-byebug'
  # Automatic Ruby code style checking tool. (https://github.com/rubocop-hq/rubocop)
  gem 'rubocop', require: false
  # Automatic performance checking tool for Ruby code. (https://github.com/rubocop-hq/rubocop-performance)
  gem 'rubocop-performance', require: false
  # Automatic Rails code style checking tool. (https://github.com/rubocop-hq/rubocop-rails)
  gem 'rubocop-rails', require: false
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # A debugging tool for your Ruby on Rails applications. (https://github.com/rails/web-console)
  gem 'web-console'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
