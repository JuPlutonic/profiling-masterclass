# README.md

## This is benchmarking master class

### Benchmark with minitest

`rails test`

### Benchmark with rspec

`rspec -f d -c`

## Profiling after program changes

First: update etalon with

`http 'localhost:3000/report?start_date=2015-07-01&finish_date=2021-12-12' > lib/etalon.html`

Second: run `ruby lib/profiling.rb` to see did those changes were a source of degradation.

### Apt install

* `sudo apt install apache2-utils`

### Run apache benchmark

* `ab -s 128 -n 3 http://localhost:3000/report\?start_date\=2015-01-12\&finish_date\=2021-02-17`

* try 2.. 3.. 4.. days...

* turn off turbo-boost and energy saving mode...

### Profile with gem stackprof

* add to url  <http://localhost:3000/report?start_date=2015-01-12&finish_date=2021-02-17>
  _&profile=json_

* open formed json-file with <https://www.speedscope.app/> to see so-called "Flamegraph"

### Other profiling instruments (stackprof - sampling, ruby-prof - tracing)

* use &profile=measure_mem

* gem 'memory_profiler'

* use &profile=ruby_prof for gem 'ruby-prof'

* trace with Flat, CallStack, Graph, callgrind CallTree views

  * use `QCachegrind` Qt app for visualization (RubyMine must have same vis-s)

* [Valgrind Massif visualier](https://github.com/KDE/massif-visualizer) - makes
  screenshots with graph of memory consumption.

## Minitest/RSpec TODOs

* make lib/report_builder_fast.rb faster

* change ./payloads/data_18.txt with ./payloads/data_6000.txt

* dont forget about profiling tools with degradation testing

* add changed 'fast' report builder to Minitest/RSpec and run benchmarking test

* test MB threshold in PigCI by adding parameter (more days) to the request spec
