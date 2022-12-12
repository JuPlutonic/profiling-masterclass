# frozen_string_literal: true

# Use derailed.rake to:
require 'bundler'
Bundler.setup

require 'derailed_benchmarks'
require 'derailed_benchmarks/tasks'

# The benchmarks will be loaded before your application,
# this is important for some benchmarks and less for others.
# This also prevents you from accidentally loading the benchmarks when you don't need them.
# Use `$ rake -f lib/tasks/derailed.rake -T` which essentially says use the file derailed.rake and list all the tasks.

namespace :perf do
  ENV['CUT_OFF'] ||= '0.1'
  ENV['USE_SERVER'] ||= 'puma'
  # Use `RAILS_ENV=development rails perf:mem` to see gems' memory usage at boot
  task mem: :environment do; end
end
