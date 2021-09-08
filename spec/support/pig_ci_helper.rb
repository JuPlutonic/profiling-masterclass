# frozen_string_literal: true

require 'pig_ci'
PigCI.start do |config|
  # Maximum memory in megabytes
  config.thresholds.memory = 10 # It will be killed by K8s!

  # Maximum time per a HTTP request
  config.thresholds.request_time = 5_000 # Milliseconds

  # Maximum database calls per a request
  config.thresholds.database_request = 62 # For the month report (31 ~ 62)
end if RSpec.configuration.files_to_run.count > 1
