Testing HTTP
************

HTTP-specific configuration
###########################

TLS/SSL
-------

Artillery will reject self-signed TLS certificates by default. To turn off verification set ``config.tls.rejectUnauthorized`` to ``false``.

Request timeout
---------------

If a response takes longer than 120 seconds Artillery will abort the request and report an ``ETIMEDOUT`` error.

To increase or decrease the default timeout set ``config.http.timeout`` to a number (in seconds).
::

  config:
    target: "http://my.app"
    http:
      timeout: 10 # Responses will now have to be sent within 10 seconds or the request will be aborted
      
When running tests, response times that increase steadily until reaching 120s (the default timeout setting) and timing out would usually indicate some kind of queuing in the target system.

Fixed connection pool
---------------------

By default Artillery will open a new connection for each new virtual user. To open and re-use a fixed number of connections instead, set `config.http.pool` to a number:
::

  config:
    target: "http://my.app"
    http:
      pool: 10 # All HTTP requests from all virtual users will be sent over the same 10 connections

This can be useful to emulate the conditions when the target would normally be behind a load-balancer and would have a fixed number of connections established at any given time.


Actions
#######

Each object in the ``flow`` array contains one key representing the HTTP method (``get``, ``put``, ``post`` and ``delete`` are supported), and the value is an object describing the request, supporting the following keys:

- ``url`` - the request URL; it will be appended to the ``target`` but can be fully qualified also
- ``json`` - a JSON object to be sent in the request body
- ``body`` - arbitrary data to be sent in the request body
- ``headers`` - a JSON object describing header key-value pairs
- ``cookie`` - a JSON object describing cookie key-value pairs
- ``capture`` - use this to capture values from the response body of a request and store those in variables

Logging
#######

Debug messages can be logged with the ``log`` action:
::

  log: "hello world!"

    
The string argument to ``log`` may include variables:
::

  log: "Current environment is set to: {{ $environment }}"


GET / POST / PUT / DELETE
#########################

Send a GET request:
::

  get:
    url: "/test"


POST some JSON:
::

  post:
    url: "/test"
    json:
      name: "Hassy"
      occupation: "software developer"


POST arbitrary data:
::

  post:
    url: "/test"
    body: "name=hassy&occupation=software%20developer"

HTTP Basic Auth
###############

HTTP Basic Auth is supported; the auth details can be sent along like this:

::

  post:
    url: "/pets"
    auth:
      user: "username"
      pass: "secretpassword"
    json:
      name: "Bluebell"
      species: "pony"

Set headers
###########

You can set headers like this:
::

  get:
    url: "/test"
    headers:
      X-My-Header: "123"


Extract and reuse parts of a response (request chaining)
########################################################

You can parse responses and reuse those values in subsequent requests.

Syntax
------

To tell Artillery to parse a response, add a ``capture`` attribute to any request spec like so:
::

  get:
    url: "/"
    capture:
      json: "$.id"
      as: "id"


The ``capture`` element must always have an ``as`` attribute which names the value for use in subsequent requests, and one of:

- a ``json`` attribute containing a `JSONPath <http://goessner.net/articles/JsonPath/>`_ expression
- an ``xpath`` attribute containing an `XPath <https://en.wikipedia.org/wiki/XPath>`_ expression
- a ``regexp`` attribute containing a regular expression (a string that gets passed to a `RegExp constructor <https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/RegExp>`_
- a ``header`` attribute containing the name of the response header whose value you want to capture
- a ``selector`` attribute containing a `Cheerio <https://github.com/cheeriojs/cheerio>`_ element selector

Optionally, it can also contain a ``transform`` attribute, which should be a snippet of JS code (as a string) transforming the value after it has been extracted from the response:
::

  get:
    url: "/journeys"
    capture:
      xpath: "(//Journey)[1]/JourneyId/text()"
      transform: "this.JourneyId.toUpperCase()"
      as: "JourneyId"


Where ``this`` refers to the *context* of the virtual user running the scenario, i.e. an object containing all currently defined variables, including the one that has just been extracted from the response.

Capturing multiple values
%%%%%%%%%%%%%%%%%%%%%%%%%

Multiple values can be captured with an array of capture specs, e.g.:

::

  get:
    url: "/journeys"
    capture:
      -
        xpath: "(//Journey)[1]/JourneyId/text()"
        transform: "this.JourneyId.toUpperCase()"
        as: "JourneyId"
      -
        header: "x-my-custom-header"
        as: "headerValue"


An example
%%%%%%%%%%

In the following example, we POST to ``/pets`` to create a new resource, capture part of the response (the id of the new resource) and store it in the variable ``id``. We then use that value in the subsequent request to load the resource and to check to see if the resource we get back looks right.
::

  -
    post:
      url: "/pets"
      json:
        name: "Mali"
        species: "dog"
      capture:
        json: "$.id"
        as: "id"
  -
    get:
      url: "/pets/{{ id }}"
      match:
        json: "$.name"
        value: "{{ name }}"

By default, every response body is captured in the variable ``$``, so the
example above could also be rewritten as:
::

  -
    post:
      url: "/pets"
      json:
        name: "Mali"
        species: "dog"
  -
    get:
      url: "/pets/{{ $.id }}"
      match:
        json: "$.name"
        value: "{{ name }}"


Cookies
#######

Cookies are remembered and re-used by individual virtual users. Custom cookies can be specified with ``cookie`` attribute in individual requests.
::

  get:
    url: "/pets/"
    cookie:
      saved: "tapir,sloth"

Forms
#####

Use the ``form`` attribute to send a form (``application/x-www-form-urlencoded``).
::

  post:
    url: "/order"
    form:
      name: "{{ name }}"
      product_slug: "book"
      inscription: "{{ dedication }}"
      gift_options: "{{ gift_option }}"      

TLS/SSL
#######

By default, Artillery will reject self-signed certificates. You can disable this behavior (for testing in a staging environment for example):

- Pass ``-k`` (or ``--insecure``) option to ``artillery run`` or ``artillery quick``
- By setting the ``config.http.tls`` property in your test script like so:

::

  config:
    target: "https://myapp.staging:3002"
    http:
      tls:
        rejectUnauthorized: false
  scenarios:
    -
      ...


Inline variables
################

Variables can defined in the ``config.variables`` section of a script and used in subsequent request templates.
::

  config:
    target: "http://app01.local.dev"
    phases:
      -
        duration: 300
        arrivalRate: 25
    variables:
      postcode:
        - "SE1"
        - "EC1"
        - "E8"
        - "WH9"
      id:
        - "8731"
        - "9965"
        - "2806"


The variables can then be used in templates as normal. For example: ``{{ id }}`` and ``{{ postcode }}``.


Variables from a file
#####################

You can create variables to use in your scenarios with values from an external CSV file.

Take this CSV file for example:
::

    dog,Leo
    dog,Figo
    dog,Mali
    cat,Chewbacca
    cat,Puss
    cat,Bonnie
    cat,Blanco
    pony,Tiki

Add ``payload`` to config:
::

  config:
    payload:
      fields:
        - "species"
        - "name"


This will make ``species`` and ``name`` variables available in scenario definitions.

Use those variables in your scenarios:
::

  post:
    url: "/pets"
    json:
      name: "{{ name }}"
      species: "{{ species }}"


Then tell ``artillery`` to use the payload file:
::

    artillery run my_test.json -p pets.csv

Loop through a number of requests
#################################

You can use the ``loop`` construct to loop through a number of requests in a scenario. For example, each virtual user will send 100 ``GET`` requests to ``/`` with this scenario:
::

  config:
    # ... config here ...
  scenarios:
    -
      flow:
        -
          loop:
            -
              get:
                url: "/"
          count: 100



If count is omitted, the loop will run *indefinitely*.

``loop`` is an array - any number of requests can be specified. Variables, cookie and response parsing will work as expected.

The current step of the loop is available inside a loop through the ``$loopCount`` variable (for example going from 1 too 100 in the example above).

Advanced: writing custom logic in Javascript
#################################

The HTTP engine has support for "hooks", which allow for custom JS functions to be called at certain points during the execution of a scenario.

- ``beforeRequest`` - called before a request is sent; request parameters (URL, cookies, headers, body etc) can be customized here
- ``afterResponse`` - called after a response has been received; the response can be inspected and custom variables can be set here

Specifying a function to run
----------------------------

``beforeRequest`` and ``afterResponse`` hooks can be set in a request spec like this:
::

  # ... a request in a scenario definition:
  post:
    url: "/some/route"
    beforeRequest: "setJSONBody"
    afterResponse: "logHeaders"


This tells Artillery to run the ``setJSONBody`` function before the request is made, and to run the ``logHeaders`` function after the response has been received.

Specifying multiple functions
-----------------------------

An array of function names can be specified too, in which case the functions will be run one after another.

Setting scenario-level hooks
----------------------------

Similarly, a scenario definition can have a ``beforeRequest``/``afterResponse`` attribute, which will make the functions specified run for every request in the scenario.

Loading custom JS code
----------------------

To tell Artillery to load your custom code, set ``config.processor`` to path to your JS file:
::

  config:
    target: "https://my.app.dev"
    phases:
      -
        duration: 300
        arrivalRate: 1
    processor: "./my-functions.js"
  scenarios:
    -
      # ... scenarios definitions here ...


The JS file is expected to be a standard Node.js module:
::

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

Function signatures
%%%%%%%%%%%%%%%%%%%

``beforeRequest``
+++++++++++++++++

A function invoked in a ``beforeRequest`` hook should have the following signature:
::
  function myBeforeRequestHandler(requestParams, context, ee, next) {
  }

Where:

- ``requestParams`` is an object given to the `Request <https://github.com/request/request>`_ library. Use this parameter to customize what is sent in the request (headers, body, cookies etc)
- ``context`` is the virtual user's context, ``context.vars`` is a dictionary containing all defined variables
- ``ee`` is an event emitter that can be used to communicate with Artillery
- ``next`` is the callback which *must* be called for the scenario to continue; it takes no arguments

``afterResponse``
+++++++++++++++++

A function invoked in an ``afterResponse`` hook should have the following signature:
::
  function myAfterResponseHandler(requestParams, response, context, ee, next) {
  }

Where:

- ``requestParams`` is an object given to the `Request <https://github.com/request/request>`_ library. Use this parameter to customize what is sent in the request (headers, body, cookies etc)
- ``response`` is likewise the response object from the `Request <https://github.com/request/request>`_ library. This object contains response headers, body etc.
- ``context`` is the virtual user's context, ``context.vars`` is a dictionary containing all defined variables
- ``ee`` is an event emitter that can be used to communicate with Artillery
- ``next`` is the callback which must be called for the scenario to continue; it takes no arguments

The ``function`` action
-----------------------

In addition to request and scenario hooks, custom functions can be called as steps in a scenario with the ``function`` action.
::
    config:
      #
      # configuration section
      #
    scenarios:
      - name: "My scenario"
        flow:
          - get:
              url: "/"
          - function: "acquireToken"
          - post:
              url: "/protected/endpont"
              json:
                token: "{{ token }}" # token variable created in the custom function
                
A function invoked in a ``function`` action should have the following signature:
::
  function myFunction(context, ee, next) {
  }

Where:

- ``context`` is the virtual user's context, ``context.vars`` is a dictionary containing all defined variables
- ``ee`` is an event emitter that can be used to communicate with Artillery
- ``next`` is the callback which must be called for the scenario to continue; it takes no arguments

Special Variables
-----------------

The ``$environment`` variable (accessible through ``context.vars.$environment``) contains the name of the environment (specified with the ``-e`` flag from the list under ``config.environments`` in the file that defines the test) and can be used to toggle specific environment-dependent behavior in custom JS functions.
