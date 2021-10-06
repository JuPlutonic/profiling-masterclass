module ApplicationHelper
  LOGGER_BAR = ('*' * 40).freeze

  # We will use visualization in a browser in flame-graph format https://speedscope.app
  def self.profile_with_stackprof(&block)
    profile = StackProf.run(mode: :wall, raw: true, &block)
    File.write('tmp/stackprof.json', JSON.generate(profile))
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

  def profile_with_stackprof(&block)
    ApplicationHelper.profile_with_stackprof(&block)
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

  # Legent: rss - Resident Set Size
  # Amount of RAM in MB, assigned to process
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
