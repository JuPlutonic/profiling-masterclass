###### Benchmark with minitest:
```rails test```

###### Benchmark with rspec
```rspec -f d -c```

##### Profiling after program changes

First: update etalon with
```http 'localhost:3000/report?start_date=2015-07-01&finish_date=2021-12-12' > lib/etalon.html```

Second: run `ruby lib/profiling.rb` to see did those changes were a source of degradation.

###### Apt install:

* sudo apt install apache2-utils

###### Run apache benchmark:

* ab -s 128 -n 3 http://localhost:3000/report\?start_date\=2015-01-12\&finish_date\=2021-02-17

* try 2.. 3.. 4.. days...

* turn off turbo-boost and energy saving mode...

###### Profile with stackprof:

* add to url http://localhost:3000/report?start_date=2015-01-12&finish_date=2021-02-17
   &profile=json

* open formed json-file with https://www.speedscope.app/ to see so-called "Flamegraph"

###### Other profiling instruments:

* gem memory profile

* ruby-prof (Flat, CallStack, Graph, callgrind, CallTree with `QCachegrind` QT-visualization)

* valgrind massif visualier - which make screenshots with graph of memory consumtion
