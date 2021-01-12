# Feedback-loop script

require 'net/http'
require 'pry'

class FeedbackLoop
  THRESHOLD_METRIC_IN_SECONDS = 4 # see Web performance optimizations stats - https://wpostats.com
  REPEATS = 3
  APPROX_BUDGET = 0.15
  DATE_FOR_TEST_RESPONSES = '2021-12-01'.freeze

  def call
    check_correctness
    current_metric = protect_from_degradation
    check_approx_budget(current_metric)
    check_final_budget
  end

  private

  def get_response(finish_date)
    uri = URI("http://localhost:3000/report?start_date=2020=07-01&finish_date=#{finish_date}")
    response = Net::HTTP.get_response(uri)
  end

  # used by the "protect_from_degradation" test
  def calculate_metric
    total_time = 0
    REPEATS.times do
      start = Time.now
      get_response(DATE_FOR_TEST_RESPONSES)
      finish = Time.now
      total_time += finish - start
    end
    total_time / REPEATS
  end

  # update etalon with
  # http 'localhost:3000/report?start_date=2020=07-01&finish_date=2021-12-01' > lib/etalon.html
  def check_correctness
    response = get_response(DATE_FOR_TEST_RESPONSES)
    result_body = response.body[/<body?(.*?)<\/body>/m,1]
    etalon_response = File.read('./lib/etalon.html')
    etalon_body = etalon_response[/<body?(.*?)<\/body>/m,1]

    if result_body == etalon_body
      puts 20 * '*' + 'Correctness test passed' + 20 * '*'
    else
      puts 20 * '*' + 'Correctness test failed' + 20 * '*'
    end
  end

  def protect_from_degradation
    calculate_metric.tap do |current_metric|
      if current_metric > THRESHOLD_METRIC_IN_SECONDS
        raise 10 * '*' + "Test on degradation: result worse than metric: #{current_metric} > #{THRESHOLD_METRIC_IN_SECONDS}" + 10 * '*'
      else
        puts 10 * '*' + "Test has passed degradation test: #{current_metric} < #{THRESHOLD_METRIC_IN_SECONDS}" + 10 * '*'
      end
    end
  end

  def check_approx_budget(current_metric)
    if current_metric < APPROX_BUDGET
      puts 10 * '*' + "Result is the gaps of APPROX_BUDGET: #{current_metric} < #{APPROX_BUDGET}" + 10 * '*'
    else
      raise 10 * '*' + "Result is not in APPROX_BUDGET yet: #{current_metric} > #{APPROX_BUDGET}" + 10 * '*'
    end
  end

  def check_final_budget; end

  FeedbackLoop.new.call
end
