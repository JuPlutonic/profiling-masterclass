# frozen_string_literal: true

require 'json'
require_relative '../lib/db_file_io.rb'
require File.expand_path('../config/environment', __dir__)
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe ReportBuilderSlow do
  before do
    File.write('payloads/data_18.txt', <<~DATA_FILE_CONTENT)
      user,0,Leida,Cira,0
      session,0,0,Safari 29,87,2016-10-23
      session,0,1,Firefox 12,118,2017-02-27
      session,0,2,Internet Explorer 28,31,2017-03-28
      session,0,3,Internet Explorer 28,109,2016-09-15
      session,0,4,Safari 39,104,2017-09-27
      session,0,5,Internet Explorer 35,6,2016-09-01
      user,1,Palmer,Katrina,65
      session,1,0,Safari 17,12,2016-10-21
      session,1,1,Firefox 32,3,2016-12-20
      session,1,2,Chrome 6,59,2016-11-11
      session,1,3,Internet Explorer 10,28,2017-04-29
      session,1,4,Chrome 13,116,2016-12-28
      user,2,Gregory,Santos,86
      session,2,0,Chrome 35,6,2018-09-21
      session,2,1,Safari 49,85,2017-05-22
      session,2,2,Firefox 47,17,2018-02-02
      session,2,3,Chrome 20,84,2016-11-25
      DATA_FILE_CONTENT
  end

  describe '#call' do
    subject(:generate_report) do
      described_class.new.call(input_filename, 'result_small_rspec.json')
    end

    let(:input_filename) { 'data_18.txt' }

    let(:expected_result) do
      JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    end

    let(:actual_result) do
      JSON.parse(File.read('payloads/result_small_rspec.json'))
    end

    context 'when using small sample file' do
      it 'creates correct report' do
        generate_report
        expect(actual_result).to eq(expected_result)
      end
    end

    # #########################################################################
    # rspec-benchmark's ".to perform_allocation" is
    #   used to limit object and memory allocations
    #
    # context 'when using big file' do
    #   let(:input_filename) { 'payloads/data_6000.txt' }

    #   it 'meets memory limit' do
    #     expect{generate_report}.to perform_allocation({String => 3_100_000, Array => 1_800_000}).bytes
    #   end
    #   it 'fits memory usage metric (in megabytes)' do
    #     call(filename, 'report.json')
    #     ram_used = `ps -o rss= -p #{Process.pid}`.to_i / 1_024
    #     expect(ram_used).to be < MEMORY_LIMIT_MB
    #   end
    # end
  end
end
