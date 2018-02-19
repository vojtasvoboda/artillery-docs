# Testing HTTP

## HTTP-specific configuration

### TLS/SSL

By default, Artillery will reject self-signed certificates. You can disable this behavior (for testing in a staging environment for example):

- Pass ``-k`` (or ``--insecure``) option to ``artillery run`` or ``artillery quick``
- By setting the ``config.http.tls`` property in your test script like so:

```json
config:
  target: "https://myapp.staging:3002"
  http:
    tls:
      rejectUnauthorized: false
scenarios:
  - ...
```

### Request timeout

If a response takes longer than 120 seconds Artillery will abort the request and report an ``ETIMEDOUT`` error.

To increase or decrease the default timeout set ``config.http.timeout`` to a number (in seconds).

```json
config:
  target: "http://my.app"
  http:
    # Responses have to be sent within 10 seconds or the request will be aborted
    timeout: 10
```

### Fixed connection pool

By default Artillery will open a new connection for each new virtual user. To open and re-use a fixed number of connections instead, set `config.http.pool` to a number:

```json
config:
  target: "http://my.app"
  http:
    pool: 10 # All HTTP requests from all virtual users will be sent over the same 10 connections
```

This can be useful to emulate the conditions when the target would normally be behind a load-balancer and would have a fixed number of connections established at any given time.

### Max sockets per virtual user

By default Artillery creates one TCP connection per virtual user. To allow for multiple sockets per virtual user (to mimic the behavior of a web browser for example), the `config.http.maxSockets` option may be set.

**Note:** this setting is per virtual user, not for the total number of sockets. To limit the total number of sockets, use the `pool` setting.

### Proxies

To send requests through a proxy, set the `HTTP_PROXY` or `HTTPS_PROXY` environment variable when running Artillery.

```sh
HTTPS_PROXY='http://user:password@myproxy.local' artillery run my_script.yml
```

If your test sends requests to more than one host and you want to exclude requests to some of those from being proxied, set the `NO_PROXY` environment variable to a comma-separated list of hosts to opt out of proxying.

```sh
NO_PROXY=github.com HTTPS_PROXY='http://user:password@myproxy.local' artillery run my_script.yml
```

## Flow actions

### GET / POST / PUT / PATCH / DELETE requests

An HTTP request object may have the following attributes:

- ``url`` - the request URL; it will be appended to the ``target`` but can be fully qualified also
- ``json`` - a JSON object to be sent in the request body
- ``body`` - arbitrary data to be sent in the request body
- ``headers`` - a JSON object describing header key-value pairs
- ``cookie`` - a JSON object describing cookie key-value pairs
- ``capture`` - use this to capture values from the response body of a request and store those in variables

Example:

```json
config:
  target: "https://example.com"
  phases:
    - duration: 10
      arrivalRate: 1
scenarios:
  - flow:
      - get:
          url: "/"
      - post:
          url: "/resource"
          json:
            hello: "world"
```

### Logging

Debug messages can be logged with the ``log`` action:

```json
config:
  target: "https://example.com"
  phases:
    - duration: 10
      arrivalRate: 1
scenarios:
  - flow:
      - log: "New virtual user running"
      - get:
          url: "/"
      - post:
          url: "/resource"
          json:
            hello: "world"
```

The string argument to ``log`` may include variables:

```json
- log: "Current environment is set to: {{ $environment }}"
```

### Set headers

Arbitrary headers may be sent with:

```json
- get:
    url: "/test"
    headers:
      X-My-Header: "123"
```

### Forms

#### URL-encoded forms (`application/x-www-form-urlencoded`)

Use the `form` attribute to send an [URL-encoded form](https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.1).

```yaml
- post:
    url: "/upload"
    form:
      name: "Homer Simpson"
      favorite_food: "donuts"
```

#### Multipart form uploads (`multipart/form-data`)

Use the `formData` attribute to send a [`multipart/form-data` form](https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2) (forms containing files, non-ASCII data, and binary data).

```yaml
- post:
    url: "/upload"
    formData:
      name: "Homer Simpson"
      favorite_food: "donuts"
```

To attach binary data [a custom JS function](#advanced-writing-custom-logic-in-javascript) can be used.

<p class="smaller" style="color: #818181; margin-top: 2em; border: 1px solid #eee; padding: 0.5em 1em; border-radius: 1em;"> <i class="hlblue fa fa-info-circle" aria-hidden="true"></i> First-class file upload support is also provided by <a href="/pro/">Artillery Pro</a> for teams requiring extensive file uploading functionality in their tests.</p>


### Extracting and reusing parts of a response (request chaining)

You can parse responses and reuse those values in subsequent requests.

#### Syntax

To tell Artillery to parse a response, add a ``capture`` attribute to any request spec like so:

```json
- get:
    url: "/"
    capture:
      json: "$.id"
      as: "id"
```

The ``capture`` element must always have an ``as`` attribute which names the value for use in subsequent requests, and one of:

- a ``json`` attribute containing a [JSONPath](http://goessner.net/articles/JsonPath/) expression
- an ``xpath`` attribute containing an [XPath](https://en.wikipedia.org/wiki/XPath) expression
- a ``regexp`` attribute containing a regular expression (a string that gets passed to a [RegExp constructor](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/RegExp>)
- a ``header`` attribute containing the name of the response header whose value you want to capture
- a ``selector`` attribute containing a [Cheerio](https://github.com/cheeriojs/cheerio) element selector

Optionally, it can also contain a ``transform`` attribute, which should be a snippet of JS code (as a string) transforming the value after it has been extracted from the response:

```json
- get:
    url: "/journeys"
    capture:
      xpath: "(//Journey)[1]/JourneyId/text()"
      transform: "this.JourneyId.toUpperCase()"
      as: "JourneyId"
```

Where ``this`` refers to the *context* of the virtual user running the scenario, i.e. an object containing all currently defined variables, including the one that has just been extracted from the response.

##### Capturing multiple values

Multiple values can be captured with an array of capture specs, e.g.:

```json
- get:
    url: "/journeys"
    capture:
      - xpath: "(//Journey)[1]/JourneyId/text()"
        transform: "this.JourneyId.toUpperCase()"
        as: "JourneyId"
      - header: "x-my-custom-header"
        as: "headerValue"
```

#### An example

In the following example, we POST to ``/pets`` to create a new resource, capture part of the response (the id of the new resource) and store it in the variable ``id``. We then use that value in the subsequent request to load the resource and to check to see if the resource we get back looks right.

```json
  - post:
      url: "/pets"
      json:
        name: "Mali"
        species: "dog"
      capture:
        json: "$.id"
        as: "id"
  - get:
      url: "/pets/{{ id }}"
      match:
        json: "$.name"
        value: "{{ name }}"
```

By default, every response body is captured in the variable ``$``, so the
example above could also be rewritten as:

```json
  - post:
      url: "/pets"
      json:
        name: "Mali"
        species: "dog"
  - get:
      url: "/pets/{{ $.id }}"
      match:
        json: "$.name"
        value: "{{ name }}"
```

### Cookies

Cookies are remembered and re-used by individual virtual users. Custom cookies can be specified with ``cookie`` attribute in individual requests.

```json
  - get:
      url: "/pets/"
      cookie:
        saved: "tapir,sloth"
```

### Looping through a number of requests

You can use the ``loop`` construct to loop through a number of requests in a scenario. For example, each virtual user will send 100 ``GET`` requests to ``/`` with this scenario:

```json
  config:
    # ... config here ...
  scenarios:
    - flow:
        - loop:
            - get:
                url: "/"
          count: 100
```

*If count is omitted, the loop will run indefinitely.*

``loop`` is an array - any number of requests can be specified. Variables, cookie and response parsing will work as expected.

The current step of the loop is available inside a loop through the ``$loopCount`` variable (for example going from 1 too 100 in the example above).

### Looping through an array

Looping through an array can be done by setting the `over` property to a literal array or the name of the variable containing an array of values.

In the following example 3 requests would be made, one for each product ID: 

```yaml
- loop:
    - get:
         url: "/products/{{ $loopElement }}"
   over:
     - id123
     - id456
     - id789
```

### (Experimental) Looping with custom logic

Let's say we want to poll an endpoint until it returns a JSON response with the top-level `status` attribute set to `"ready"`:

```yaml
- loop:
    - think: 5
    - get:
        url: "/some/endpoint"
        capture:
          - json: $.status
            as: "status"
  whileTrue: "myFunction"
```

```javascript
function myFunction(context, next) {
  const continueLooping = context.vars.status !== 'ready';
  return next(continueLooping); // call back with true to loop again
}
```

**NOTE:** `whileTrue` true takes precendence over `count` and `over` attributes if either of those is specified.

## Advanced: writing custom logic in Javascript

The HTTP engine has support for "hooks", which allow for custom JS functions to be called at certain points during the execution of a scenario.

- ``beforeRequest`` - called before a request is sent; request parameters (URL, cookies, headers, body etc) can be customized here
- ``afterResponse`` - called after a response has been received; the response can be inspected and custom variables can be set here

### Loading custom JS code

To tell Artillery to load your custom code, set ``config.processor`` to path to your JS file:

```json
config:
  target: "https://my.app.dev"
  phases:
    -
      duration: 300
      arrivalRate: 1
  processor: "./my-functions.js"
scenarios:
  - # ... scenarios definitions here ...
```

The JS file is expected to be a standard Node.js module:

```javascript
  //
  // my-functions.js
  //
  module.exports = {
    setJSONBody: setJSONBody,
    logHeaders: logHeaders
  }

  function setJSONBody(requestParams, context, ee, next) {
    return next(); // MUST be called for the scenario to continue
  }

  function logHeaders(requestParams, response, context, ee, next) {
    console.log(response.headers);
    return next(); // MUST be called for the scenario to continue
  }
```

### Specifying a function to run

``beforeRequest`` and ``afterResponse`` hooks can be set in a request spec like this:

```json
  # ... a request in a scenario definition:
  - post:
      url: "/some/route"
      beforeRequest: "setJSONBody"
      afterResponse: "logHeaders"
```

This tells Artillery to run the ``setJSONBody`` function before the request is made, and to run the ``logHeaders`` function after the response has been received.

### Specifying multiple functions

An array of function names can be specified too, in which case the functions will be run one after another.

### Setting scenario-level hooks

Similarly, a scenario definition can have a ``beforeRequest``/``afterResponse`` attribute, which will make the functions specified run for every request in the scenario.

### Function signatures

#### `beforeRequest`

A function invoked in a ``beforeRequest`` hook should have the following signature:

```javascript
function myBeforeRequestHandler(requestParams, context, ee, next) {
}
```

Where:

- ``requestParams`` is an object given to the [Request](https://github.com/request/request) library. Use this parameter to customize what is sent in the request (headers, body, cookies etc)
- ``context`` is the virtual user's context, ``context.vars`` is a dictionary containing all defined variables
- ``ee`` is an event emitter that can be used to communicate with Artillery
- ``next`` is the callback which *must* be called for the scenario to continue; it takes no arguments

#### `afterResponse`

A function invoked in an ``afterResponse`` hook should have the following signature:

```javascript
function myAfterResponseHandler(requestParams, reponse, context, ee, next) {
}
```

Where:

- ``requestParams`` is an object given to the [Request](https://github.com/request/request) library. Use this parameter to customize what is sent in the request (headers, body, cookies etc)
- ``response`` is likewise the response object from the [Request](https://github.com/request/request) library. This object contains response headers, body etc.
- ``context`` is the virtual user's context, ``context.vars`` is a dictionary containing all defined variables
- ``ee`` is an event emitter that can be used to communicate with Artillery
- ``next`` is the callback which must be called for the scenario to continue; it takes no arguments
