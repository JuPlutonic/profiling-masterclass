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
# Use `RAILS_ENV=development rails perf:mem` to run one of listed tasks

namespace :perf do
  task mem: :environment do; end
end
