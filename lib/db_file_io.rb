# frozen_string_literal: true

# require 'json'

require_relative 'report_builder_slow'
# require_relative 'report_builder_fast'

# Use db_file_io to build report (it reads/parses users-sessions from TXT file
# and forms JSON report, creates users-sessions in DB)
# SOURCE_FILE = 'data_6000.txt'.freeze

ReportBuilderSlow.new.call('data_18.txt', 'report_slow_small.json')
# ReportBuilderFast.new.call(SOURCE_FILE, 'report_fast_big.json')
