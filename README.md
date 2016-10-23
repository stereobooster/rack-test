# Rack JSON server

## trialday.rb

Niave and simple implementation. It doesn't try to handle zillion of possible malformed inputs and outputs.

## Benchmark

### Webrick

```
which llvm-config-3.6
RUBY_CONFIGURE_OPTS="--llvm-config=/opt/boxen/homebrew/bin/llvm-config-3.6" rbenv install rbx-3.20

ruby -v
rubinius 3.20 (2.2.2 93228c48 2016-03-25 3.5.1) [x86_64-darwin15.6.0]

RACK_ENV=production rackup config.ru -p 3000

wrk --threads 2 --duration 10 http://localhost:3000/bla
Running 10s test @ http://localhost:3000/bla
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    22.09ms   30.02ms 244.37ms   93.79%
    Req/Sec   315.24     84.71   430.00     83.67%
  6206 requests in 10.05s, 1.18MB read
  Socket errors: connect 0, read 6, write 0, timeout 0
Requests/sec:    617.36                                                <-- 0.6k
Transfer/sec:    119.99KB
```

```
ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]

wrk --threads 2 --duration 10 http://localhost:3000/bla
Running 10s test @ http://localhost:3000/bla
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    14.42ms    6.20ms  63.79ms   74.74%
    Req/Sec   352.19     37.70   434.00     68.00%
  7028 requests in 10.03s, 1.33MB read
Requests/sec:    701.04                                                <-- 0.7k
Transfer/sec:    136.24KB
```

### Passenger

```
brew install passenger
brew install nginx --with-passenger

nginx -v
nginx version: nginx/1.10.2
ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]
passenger -v
Phusion Passenger 5.0.30

nginx -c full_path/nginx.conf

wrk --threads 2 --duration 10 http://localhost:3000/bla
Running 10s test @ http://localhost:3000/bla
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.72ms    1.81ms  35.01ms   94.06%
    Req/Sec     3.41k   567.41     6.84k    78.61%
  68189 requests in 10.10s, 16.19MB read
Requests/sec:   6751.03                                                <--  6k
Transfer/sec:      1.60MB
```

### Puma

```
RACK_ENV=production puma config.ru -p 3000

ruby -v
rubinius 3.20 (2.2.2 93228c48 2016-03-25 3.5.1) [x86_64-darwin15.6.0]

 wrk --threads 2 --duration 10 http://localhost:3000/bla
Running 10s test @ http://localhost:3000/bla
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    25.39ms   42.52ms 346.28ms   86.78%
    Req/Sec     1.21k     0.88k    4.08k    65.66%
  24091 requests in 10.10s, 2.07MB read
Requests/sec:   2386.19                                                <--  2k
Transfer/sec:    209.73KB
```

```
ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]

wrk --threads 2 --duration 10 http://localhost:3000/bla
Running 10s test @ http://localhost:3000/bla
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.01ms  651.39us  16.22ms   81.48%
    Req/Sec     5.13k   413.94     5.62k    84.65%
  103196 requests in 10.10s, 8.86MB read
Requests/sec:  10217.50                                                <-- 10k
Transfer/sec:      0.88MB
```

### H2O

```
brew install h2o

h2o -v
h2o version 2.0.4
OpenSSL: OpenSSL 1.0.2j  26 Sep 2016
mruby: YES

h2o

wrk --threads 2 --duration 10 http://localhost:3000/bla
Running 10s test @ http://localhost:3000/bla
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   579.44us  467.42us  22.04ms   93.63%
    Req/Sec     9.05k     0.88k   10.56k    74.26%
  181927 requests in 10.10s, 29.49MB read
Requests/sec:  18013.72                                                <-- 18k
Transfer/sec:      2.92MB
```

### Rust

```
cd rust-json-api
cargo --version
cargo 0.13.0-nightly (d263690 2016-07-07)
cargo run --release

wrk --threads 2 --duration 10 http://localhost:3000/bla
Running 10s test @ http://localhost:3000/bla
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   106.09us   89.36us   6.50ms   96.69%
    Req/Sec    22.32k     4.47k   31.94k    58.42%
  448644 requests in 10.10s, 69.31MB read
Requests/sec:  44415.80                                                <-- 44k
Transfer/sec:      6.86MB
```

## Next

NodeJS? GO? OCaml? Erlang? Nginx + mruby?

