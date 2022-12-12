# frozen_string_literal: true

# Use db_file_io to:
# • serialize users-sessions from TXT file
# • form JSON report
# • create users-sessions in DB
# • profile and benchmark these actions
module Benchmarks
  class DbFileIo
    # require_relative '../slow_report_builder'
    require_relative '../fast_report_builder'
    # SOURCE_FILE = 'data_6000.txt'.freeze
    MEMORY_LIMIT_MB = 70

    # SlowReportBuilder.new.call('data_18.txt', 'slow_report_small.json')
    FastReportBuilder.new.call('data_18.txt', 'fast_report_small.json')
    #                           SOURCE_FILE               _big

    # Benchmark.1: fits in +memory usage metric+ (in megabytes)
    # Legend: rss - Resident Set Size (amount of RAM in MB, assigned to process)
    # private def memory_usage_metric
    #   call(filename, 'report.json')
    #   ram_used = `ps -o rss= -p #{Process.pid}`.to_i / 1_024
    #   expect(ram_used).to be < MEMORY_LIMIT_MB
    # end
  end
end
