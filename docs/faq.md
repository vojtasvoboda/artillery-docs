# F.A.Q.

This section answers some of the common questions about Artillery and its usage.

### "High CPU" warnings

#### I got a "High CPU" warning from Artillery, what does that mean?

Artillery will monitor its own CPU usage and print warnings when that exceeds 80%.

Artillery is written in [Node.js](https://nodejs.org/en/). As a rule of thumb, Node.js processes should never be allowed to go anywhere near max CPU usage. That's due to how Node.js works under the hood. At high CPU loads, Node.js event loop will be competing with the V8 garbage collector over CPU time, which will cause further performance degradation. The impact of that on your tests is inaccurate results - fewer virtual users than requested may be launched, and latency reports will be skewed as it measurements will be affected by event loop lag.

#### Common causes

##### High arrivalRate settings

The most common cause of high CPU usage is an `arrivalRate` which is too high. Consider the following phase definition:

```yaml
config:
  phases:
    - arrivalRate: 100
      duration: 60
```

By default, each virtual user creates a new TCP connection. That means Artillery will attempt to establish 100 TCP connections *per second*. Establishing a TCP connection is relatively expensive and can lead to high CPU usage.

##### CPU heavy custom JS code

If your tests use custom JS code, there may be CPU-heavy hotspots in one of the functions or a dependency.

#### Mitigation

**Reduce `arrivalRate` values**

Bear in mind that a given `arrivalRate` does **not** directly correspond to requests sent per second. If you need to send a large number of requests over a single connection, use the `loop` action. If you're testing an HTTP server and don't need a new TCP connection for each new virtual user, use the [`pool` config option](/docs/http-reference/#fixed-connection-pool).

**Profile and optimize custom JS code**

If you suspect that custom JS functions could be using a lot of CPU, consider profiling and optimizing that code.

**Use a system with more CPU resources**

Re-running the test on a machine with a more powerful CPU may help increase performance.

**Run a distributed load test**

For situations in which high `arrivalRate`s are required running a distributed test is a good solution. Multiple Artillery instances can be run and coordinated across a fleet of machines with an orchestration tool like [Ansible](https://www.ansible.com/) or by using [Artillery Pro](https://artillery.io/pro.html).
