# frozen_string_literal: true

# Use db_file_io to:
# • serialize users-sessions from TXT file
# • form JSON report
# • create users-sessions in DB
# • profile and benchmark these actions
module Benchmarks
  class DbFileIo
    require_relative '../report_builder_slow'
    # require_relative '../report_builder_fast'
    # SOURCE_FILE = 'data_6000.txt'.freeze
    MEMORY_LIMIT_MB = 70

    ReportBuilderSlow.new.call('data_18.txt', 'report_slow_small.json')
    # ReportBuilderFast.new.call(SOURCE_FILE, 'report_fast_big.json')

    # private

    # Benchmark.1: fits in +memory usage metric+ (in megabytes)
    # def memory_usage_metric
    #   call(filename, 'report.json')
    #   ram_used = `ps -o rss= -p #{Process.pid}`.to_i / 1_024
    #   expect(ram_used).to be < MEMORY_LIMIT_MB
    # end
  end
end
