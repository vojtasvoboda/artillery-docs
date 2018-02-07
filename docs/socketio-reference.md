# Testing Socket.io

[Socket.io](http://socket.io) is a popular library for building real-time event-based applications.  Artillery has first-class support for load testing Socket.io. Set the ``engine`` attribute of a scenario definition to ``socketio`` to enable the Socket.io engine.

## Socket.io-specific configuration

### Query

[Query parameters](https://socket.io/docs/client-api/#with-query-parameters) can be specified as a string or as a dictionary:

```yaml
config:
  target: "https://myapp.staging:3002"
  socketio:
    query: "user_id=0xc0ffee&color=blue"
```

or:

```yaml
config:
  target: "https://myapp.staging:3002"
  socketio:
    query:
      user_id: "0xc0fee"
      color: "blue"
```

### Path

[A custom path](https://socket.io/docs/client-api/#with-custom-path) may be set.

In this example the virtual users will connect to the `admin` namespace with the custom path `mypath`.

```yaml
config:
  target: "https://myapp.staging:3002/admin"
  socketio:
    query:
      path: "/mypath"
```

### Transports

You can [skip long-polling](https://socket.io/docs/client-api/#with-websocket-transport-only) and specify that a websocket transport be used straightaway:

```yaml
config:
  target: "https://myapp.staging:3002/admin"
  socketio:
    transports: ["websocket"]
```

## Flow actions

The Socket.io engine allows for [HTTP actions](http-reference/#flow-actions) actions to be used in scenarios alongside ``emit``, which is the main Socket.io action.

### `emit`

The ``emit`` action supports the following attributes:

1. ``channel`` - the name of the socket.io channel to emit to
2. ``data`` - the data to emit
3. ``response`` - optional object if you want to wait for a response:
    - ``channel`` - the name of the channel where the response is received.
    - ``data`` - the data to verify is in the response
4. ``namespace`` - optional namespace that this action executes in

**Notes:**

- `data` can only be a single value; multiple arguments are not yet supported
- If you emit to a specific namespace, the response data is expected within the same namespace.

#### Example

```json
scenarios:
  - engine: "socketio"
    flow:
      - emit:
          channel: "echo"
          data: "hello"
          response:
            channel: "echoed"
            data: "hello"
      - emit:
          channel: "echo"
          data: "world"
          response:
            channel: "echoed"
            data: "world"
      - think: 1
      - emit:
          channel: "echo"
          data: "do not care about the response"
      - emit:
          channel: "echo"
          data: "still do not care about the response"
      - think: 1
      - emit:
          channel: "echo"
          data: "emit data to namespace /nsp1"
          namespace: "/nsp1"
      - emit:
          channel: "echo"
          data: "emit data to namespace /nsp2"
          namespace: "/nsp2"
      - think: 1
      - emit:
          channel: "echo"
          data: "hello"
          namespace: "/nsp1"
          response:
            channel: "echoed"
            data: "hello in /nsp1"
```

### Mixing in HTTP actions

HTTP and Socket.io actions can be combined in the same scenario (a common scenario when testing servers based on [Express.js](http://expressjs.com/)):

```json
  config:
    target: "http://127.0.0.1:9092"
    phases:
      - duration: 10
        arrivalRate: 1
  scenarios:
    - engine: "socketio"
      flow:
        - get:
            url: "/test"
        - emit:
            channel: "echo"
            data: "hello"
            response:
              channel: "echoed"
              data: "hello"
        - emit:
            channel: "echo"
            data: "world"
            response:
              channel: "echoed"
              data: "world"
        - think: 1
        - emit:
            channel: "echo"
            data: "do not care about the response"
        - emit:
            channel: "echo"
            data: "still do not care about the response"
        - think: 1
```


### Example: Connecting Without Sending Data

You can use `think` to emulate clients connecting to the app and listening without sending anything themselves.

```yaml
config:
  target: "http://127.0.0.1:9092"
  phases:
    - duration: 3600
      arrivalRate: 5
scenarios:
  - engine: "socketio"
    flow:
      - think: 600 # do nothing for 10m and disconnect
```
