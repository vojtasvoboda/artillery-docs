Basic Concepts
**************

10,000 foot view
----------------

Artillery is a tool that you can use to run load-tests.

You write your load testing scripts and tell Artillery to run them. Scripts are written in YAML, with the option to write some Javascript for really advanced stuff.

Your load testing scripts have two main parts to them - config and scenarios.

The ``config`` section
======================

The **config** part is where you specify the target (such as a website address), the load progression (telling Artillery for example to create 20 virtual users every second for 10 minutes), and can set a variety of other options (such as HTTP timeout setting etc).

The ``scenarios`` section
=========================

The **scenarios** is where you define what virtual users will be doing. A scenario is a description of a typical user session in the application. For example, in an e-commerce application a common scenario is to search for a product, add it to cart and check out. In a chat application, it may be to connect to the server, send a few messages, lurk for a while and then disconnect.

In a little more detail
-----------------------

Artillery's main purpose is to simulate realistic load on complex applications, and as such it works with the concepts of **virtual users**, that arrive to use the application in **phases**. Each users picks and runs one of the pre-defined **scenarios**, which describe a sequence of actions (HTTP requests, WebSocket messages etc) that exercise a particular part of the application or simulate a common flow through the application.

**Example**: a test for an e-commerce API might define one scenario:

1. POST a search keyword to the `search` endpoint
2. Parse the results and save the id of the first search result
3. GET the `details` endpoint with the id from step (2)
4. POST to the `cart` endpoint with the same id after pausing for 3 seconds

And the same test could define 3 load phases:
1. A warm up phase with the **arrival rate** of 5 virtual users/second that last for 60 seconds.
2. A ramp up phase where we go from 5 to 50 new virtual user arrivals over 120 seconds.
3. The final high load phase with the arrival rate of 50 that lasts for 600 seconds.

The full test script would look like this:

::

  config:
    target: "https://staging1.local"
    phases:
      -
        duration: 60
        arrivalRate: 5
      -
        duration: 120
        arrivalRate: 5
        rampTo: 50
      -
        duration: 600
        arrivalRate: 50
    payload:
      path: "keywords.csv"
      fields:
        - "keywords"
  scenarios:
    -
      name: "Search and buy"
      flow:
        -
          post:
            url: "/search"
            body: "kw={{ keywords }}"
            capture:
              json: "$.results[0].id"
              as: "id"
        -
          get:
            url: "/details/{{ id }}"
        -
          think: 3
        -
          post:
            url: "/cart"
            json:
              productId: "{{ id }}"

(**Note**: test scripts can be written as either JSON and YAML - whichever you prefer.)

**Next:**

- See the full set of options available for **defining load phases**, **randomizing requests with data from external CSV files** and other configuration options in `Test Script Reference <script_reference.html>`_.
- Learn about **sending HTTP requests**, **parsing and capturing responses** and other HTTP-specific features in `HTTP Reference <testing_http.html>`_.
