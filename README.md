# README

Apt install:

* sudo apt install apache2-utils

Run apache benchmark:

* ab -s 128 -n 3 http://localhost:3000/report\?start_date\=2021-01-12\&finish_date\=2021-01-12

* try 2.. 3.. 4.. days...

* turn off turbo-boost and energo savings...

Profile with stackprof:

* add to url http://localhost:3000/report?start_date=2021-01-12&finish_date=2021-01-12
   &profile=json

* open formed json-file with https://www.speedscope.app/ to see so-called "Flamegraph"

Other profiling instruments:

* gem memory profile

* ruby-prof (Flat, CallStack, Graph, callgrind, CallTree with `QCachegrind` QT-visualization)

* valgrind massif visualier - which make screenshots with graph of memory consumtion
