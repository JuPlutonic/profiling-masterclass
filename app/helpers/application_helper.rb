module ApplicationHelper
  LOGGER_BAR = ('*' * 40).freeze

  # We will use visualization of FlameGraph in json format (for https://speedscope.app)
  #   or in raw format
  def self.profile_with_stackprof(json:, &block)
    profile = StackProf.run(mode: :wall, raw: true, &block)
    return File.write('tmp/stackprof.json', JSON.generate(profile)) if json

    File.write('tmp/stackprof.raw',  profile)
  end

  def self.wrap_in_mem_prof
    mem_before = mem_usage
    yield

    mem_after = mem_usage
    log_memory_usage(mem_after - mem_before)
  end

  def self.profile_with_ruby_prof
    RubyProf.measure_mode = RubyProf::MEMORY
    profile = RubyProf.profile { yield }
    printer = RubyProf::CallTreePrinter.new(profile)
    printer.print(path: 'tmp', profile: 'rubyprof')
  end

  def profile_with_stackprof_json(&block)
    ApplicationHelper.profile_with_stackprof(json: true, &block)
  end

  def profile_with_stackprof_raw(&block)
    ApplicationHelper.profile_with_stackprof(json: false, &block)
  end

  def wrap_in_mem_prof(&block)
    GC.start(full_mark: true, immediate_sweep: true)
    GC.disable
    ApplicationHelper.wrap_in_mem_prof(&block)
  end

  def profile_with_ruby_prof(&block)
    ApplicationHelper.profile_with_ruby_prof(&block)
  end

  private

  # Legend: rss - Resident Set Size (amount of RAM in MB, assigned to process)
  def self.mem_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1_024 # Better than KBs and #{$$}
  end

  def self.log_memory_usage(mem)
    text = case Rails.env
           when 'development', 'test'
             "#{mem} MB" + "\n" + LOGGER_BAR
           else
             "#{mem} MB".rjust(96) + "\n" + LOGGER_BAR.rjust(129)
    end
    Rails.logger.info(LOGGER_BAR + "\n" + text)
  end
end
