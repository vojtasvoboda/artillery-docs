# Basic Concepts

This section covers some high level basic concepts that are important to understand for day to day Artillery usage. Everything on this page is recommended reading for anyone using Artillery, even if you have used other load testing tools in the past.

## The High-level View

Artillery is a tool that you can use to run load tests.

You write your load testing scripts and tell Artillery to run them. Scripts are written in YAML, with the option to write Javascript (using any `npm` module if needed) to write custom testing logic.

Artillery’s main purpose is to simulate realistic load on complex applications, and as such it works with the concepts of **virtual users**, that *arrive to use the application in phases*. Each users picks and runs one of the pre-defined scenarios, which describe a sequence of actions (HTTP requests, WebSocket messages etc) that exercise a particular part of the application or simulate a common flow through the application.

## Example: Testing An E-Commerce API ##

A test for an e-commerce API might define this scenario:

1. `POST` a search keyword to the search endpoint. We'd want to use a variety of search keywords (for example corresponding to the most popular 200 products).
2. Parse the JSON response and save the id of the first search result
3. `GET` the details endpoint with the id from step (2)
4. `POST` to the cart endpoint with the same id after pausing for 3 seconds

The same test could define 3 load phases:

1. A warm up phase with the arrival rate of 5 virtual users/second that last for 60 seconds. This phase is short and light to allow the application to warm up.
2. A ramp up phase where we go from 5 to 50 new virtual user arrivals over 120 seconds.
3. The final high load phase with the arrival rate of 50 that lasts for 600 seconds.

## Putting A Test Script Together ##

Your load testing scripts have two main parts to them - `config` and `scenarios`.

### The `config` Section ###

The `config` part is where you specify the **target** (such as the address of the API server under test), the **load progression** (telling Artillery for example to create 20 virtual users every second for 10 minutes), and can set a variety of other options such as HTTP timeout settings, or TLS settings.

### The `scenarios` Section ###

This section is where you define what **virtual users** created by Artillery will be doing.

A scenario is a description of a typical user session in the application. For example, in an e-commerce application a common scenario is to search for a product, add it to cart and check out. In a chat application, it may be to connect to the server, send a few messages, lurk for a while and then disconnect.

### The Example Script ###

The Artillery script for the ecommerce example above would look like this:

```json
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
```

(**Note**: test scripts can be written as either YAML or JSON - whichever you prefer. YAML is the recommended format since it allows comments.)

**Next:**

- See the full set of options available for **defining load phases**, **randomizing requests with data from external CSV files** and other configuration options in [Test Script Reference](script-reference).
- Learn about **sending HTTP requests**, **parsing and capturing responses** and other HTTP-specific features in [HTTP Reference](http-reference).


<!--
TODO: Show an example Artillery log and explain the metrics it gives you.
-->
