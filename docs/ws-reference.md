# Testing WebSockets

Set the ``"engine"`` attribute of a scenario definition to ``"ws"`` to use WebSockets (the default engine is HTTP).

Two kinds of actions are supported: ``send`` and ``think``.

The underlying WebSocket client can be configured with a ``"ws"`` section in the ``"config"`` section of your test script. For a list of available options, please see [WS library docs](https://github.com/websockets/ws/blob/master/doc/ws.md#new-wswebsocketaddress-protocols-options).

## Example

```json
  config:
    target: "wss://echo.websocket.org"
    phases:
      - duration: 20
        arrivalRate: 10
    ws:
      # Ignore SSL certificate errors
      # - useful in *development* with self-signed certs
      rejectUnauthorized: false
  scenarios:
    - engine: "ws"
      flow:
        - send: "hello"
        - think: 1
        - send: "world"
```

The WebSocket engine does not support parsing and reusing responses yet.
