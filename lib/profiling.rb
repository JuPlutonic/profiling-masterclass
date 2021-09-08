# frozen_string_literal: true

require 'net/http'
require 'pry'

# Profiling/testing for feedback-loop speed-up
class FeedbackLoop
  THRESHOLD_METRIC_IN_SECONDS = 4 # see Web performance optimizations stats - https://wpostats.com
  REPEATS = 21
  APPROX_BUDGET = 0.15
  DATE_FOR_TEST_RESPONSES = '2021-12-12'.freeze
  BAR = ('*' * 10).freeze

  def call
    check_correctness
    current_metric = protect_from_degradation
    check_approx_budget(current_metric)
    check_final_budget
  end

  private

  def get_response(finish_date)
    uri = URI("http://localhost:3000/report?start_date=2015-07-01&finish_date=#{finish_date}")
    response = Net::HTTP.get_response(uri)
  end

  # used by the "protect_from_degradation" test
  # :reek:DuplicateMethodCall { max_calls: 2 }
  def calculate_metric
    (0...REPEATS).collect { start = Time.now; get_response(DATE_FOR_TEST_RESPONSES); Time.now - start }.sum / REPEATS
    # REPEATS.times.sum { start = Time.now; get_response(DATE_FOR_TEST_RESPONSES); Time.now - start } / REPEATS
  end

  # update etalon/standard with
  # http 'localhost:3000/report?start_date=2015-07-01&finish_date=2021-12-12' > lib/etalon.html
  def check_correctness
    response = get_response(DATE_FOR_TEST_RESPONSES)
    result_body = response.body[/<body?(.*?)<\/body>/m, 1]
    etalon_response = File.read('./lib/etalon.html')
    # w/o CSRF token, only body:
    etalon_body = etalon_response[/<body?(.*?)<\/body>/m, 1]

    puts BAR + "\t\tCorrectness test passed:#{result_body == etalon_body}\t\t" + BAR
  end

  def protect_from_degradation
    calculate_metric.tap do |current_metric|
      puts
      if current_metric > THRESHOLD_METRIC_IN_SECONDS
        raise BAR + "Test on degradation: result worse tha n metric: #{current_metric} > #{THRESHOLD_METRIC_IN_SECONDS}" + BAR
      else
        puts BAR + "Test has passed degradation test: #{current_metric} < #{THRESHOLD_METRIC_IN_SECONDS}" + BAR
      end
    end
  end

  def check_approx_budget(current_metric)
    puts
    if current_metric < APPROX_BUDGET
      puts BAR + "\tResult is the gaps of APPROX_BUDGET:\t#{current_metric} < #{APPROX_BUDGET}" + BAR
    else
      raise BAR + "Result is not in APPROX_BUDGET yet:\t#{current_metric} > #{APPROX_BUDGET}" + BAR
    end
  end

  def check_final_budget; end

  FeedbackLoop.new.call
end
