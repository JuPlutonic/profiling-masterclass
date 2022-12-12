# README.md

## This is benchmarking master class

### Benchmark json importing

* minitest based: `rails test`

* rspec based: `rspec -f d -c`


## Profiling after program changes

1. on main/master branch update etalon with

`http 'localhost:3000/report?start_date=2015-07-01&finish_date=2021-12-12' > payloads/etalon.html`

2. checkout branch with changes and run `ruby app/lib/profiling.rb` to see if those changes was a source of degradation

### Run `Apache Benchmark`

* find in Linux repositories apache2-utils and install it (on deb-based linux
`sudo apt install apache2-utils`)

* run `ab -s 128 -n 3 http://localhost:3000/report\?start_date\=2015-01-12\&finish_date\=2021-02-17`

* try to change `start_date` and `finish_date` and set period to 2.. 3.. 4.. days, month and years

* don't forget to turn off Turbo Boost/PowerTune and power saving mode on your machine…


### Memory profiling instruments (ruby-prof — tracing)

* use *&profile=measure_mem* to run simple memory profiling implemented in ApplicationHelper

* use *&profile=ruby_prof* for gem 'ruby-prof' and use output file `rubyprof.callgrind.out.xxxxx` with a visualizer

* run `QCachegrind` Qt app for visualization and use one of these views

  - Flat

  - CallStack

  - Graph

  - callgrind (CallTree)

* use [Valgrind Massif visualizer](https://github.com/KDE/massif-visualizer) which
  makes screenshots with graph of memory consumption

> RubyMine must have build-in Graph visualization

> gem 'memory_profiler' provides similar to 'ruby-prof' memory usage information


### Dynamic profiling instruments (derailed_benchmarks / pig-ci-rails)

1. use derailed_benchmarks with my Rake task and profile memory usage by gems at boot:

   ```sh
   # to cut off files with insignificant memory usage to help eliminate noise
   #  the task is using 0.1 MiB for ENV['CUT_OFF'] by default
   CUT_OFF=0.3 RAILS_ENV=development rake perf:mem
   CUT_OFF=0 RAILS_ENV=development rake perf:mem
   ```

2. test MB threshold in PigCI

  - configure threshold in the `spec/rspec_helper.rb` file

  - run report_spec request spec (it uses `load_seed`, but it's better to use files from `payloads/`
    to get better report)

  - all other tests must be with `describe … , pig_ci: false do` in their RSpec metadata

  - check pig-ci's resulting report in `pig-ci/index.html` file


### How to see FlameGraph (stackprof — sampling)

Add _&profile=json_ to report forming url <http://localhost:3000/report?start_date=2015-01-12&finish_date=2021-02-17>
  and the upload formed json file `tmp/stackprof.json` to web app <https://www.speedscope.app/>

```cpp
or to generate SVG image add to that report forming url
```
  _&profile=raw_ and then pass `tmp/stackprof.raw` to [flamegraph.pl script](https://github.com/brendangregg/FlameGraph) in console

---

> TASKS:
>
> * make `app/lib/fast_report_builder.rb` faster or begin with `app/lib/slow_report_builder.rb`
>
>   - current "fast" budget is **APPROX_BUDGET = 0.15**, THRESHOLD_METRIC_IN_SECONDS = 0.2, see `app/lib/profiling.rb`
>
>   - use prefix "faster_" for report's name, by editing `app/lib/benchmarks/db_file_io.rb` file
>
> * change payloads/data_18.txt with payloads/data_6000.txt
>
>   - don't forget to change use postfix "\_small" with "\_big" for report's file name, see the `db_file_io.rb` file
>
> * add changed "faster" report builder to Minitest/RSpec and run benchmarking test
>
> * use more derailed_benchmarks gem to perform [soak][soak_testing] (endurance) testing

[soak_testing]: https://en.wikipedia.org/w/index.php?title=Software_performance_testing#Soak_testing
