# Getting Started With Artillery

## Install Node.js

Artillery is written in [Node.js](http://nodejs.org/) (but you do not need to know Node.js or JS to use Artillery). Grab the appropriate package from [nodejs.org](http://nodejs.org/en/download) or install Node.js with your favorite package manager first. We recommend **Node 7** for running Artillery, but any version above 4 will work.

## Install Artillery

Once Node.js is installed, install Artillery with:

```bash
npm install -g artillery
```

To check that the installation succeeded, run:

```bash
artillery -V
```

You should see Artillery print its version if the installation has been successful.

You are ready to run your first load test now!

(If you like dinosaurs, you can try `artillery dino` too.)

## Run a quick test

Artillery has a `quick` command which allows you to use it for ad-hoc testing (in a manner similar to `ab`). Run:

`bash
artillery quick --count 10 -n 20 https://artillery.io/
`

This command will create 10 "virtual users" each of which will send 20 HTTP `GET` requests to `https://artillery.io/`.

<!--
You should see something like this printed on your terminal:

`shell

`
-->

## Run a test script

While the `quick` command can be useful for very simple tests, the full power of Artillery lies in being able to simulate *realistic* user behavior with scenarios. Let’s see how we’d run one of those.

Copy the following code into a `hello.yml` file:

```json
config:
  target: 'https://artillery.io'
  phases:
    - duration: 60
      arrivalRate: 20
  defaults:
    headers:
      x-my-service-auth: '987401838271002188298567'
scenarios:
  - flow:
    - get:
        url: "/docs"
```

### What our test does

In this script, we specify that we are testing a service running on `https://artillery.io` which will be talking to over HTTP. We define one *load phase*, which will last 60 seconds with 20 new *virtual users* (arriving every second (on average).

Then we define one possible scenario for every new virtual user to pick from, which consists of one `GET` request.

We also set an `x-my-service-auth` header to be sent with every request.

### Running the test

Run the test with:

`bash
artillery run hello.yml
`

As Artillery runs the test, you should see something like this printed to your terminal:

`text
artillery run hello.yml

Phase 0 started - duration: 30s
title = Welcome to the Artillery documentation! &mdash; Artillery 2 documentation
title = Welcome to the Artillery documentation! &mdash; Artillery 2 documentation
title = Welcome to the Artillery documentation! &mdash; Artillery 2 documentation
title = Welcome to the Artillery documentation! &mdash; Artillery 2 documentation
`

Followed by:

```text
Complete report @ 2017-08-08T17:32:36.653Z
  Scenarios launched:  300
  Scenarios completed: 300
  Requests completed:  600
  RPS sent: 18.86
  Request latency:
    min: 52.1
    max: 11005.7
    median: 408.2
    p95: 1727.4
    p99: 3144
  Scenario duration:
    min: 295
    max: 11127
    median: 743.1
    p95: 3026.5
    p99: 4632.2
  Scenario counts:
    0: 300 (100%)
  Codes:
    200: 300
    302: 300
```

- `Scenarios launched` is the number of virtual users created in the preceding 10 seconds (or in total for the final report)
- `Scenarios completed` is the number of virtual users that completed their scenarios in the preceding 10 seconds (or in the whole test). Note: this is the number of completed sessions, not the number of sessions started and completed in a 10 second interval.
- `Requests completed` is the number of HTTP requests and responses or WebSocket messages sent
- `RPS sent` is the average number of requests per second completed in the preceding 10 seconds (or throughout the test)
- `Request latency` and `Scenario duration` are in milliseconds, and p95 and p99 values are the 95th and 99th [percentile](https://en.wikipedia.org/wiki/Percentile) values (a request latency `p99` value of 500ms means that 99 out of 100 requests took 500ms or less to complete).

  If you see `NaN` ("not a number") reported as a value, that means not enough responses have been received to calculate the percentile.
- `Codes` is the count of HTTP response codes.

If there are any errors (such as socket timeouts), those will be printed under `Errors` in the report as well.
