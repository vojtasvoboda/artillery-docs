Debugging your scripts
************

Artillery can be configured to print debug information as it's running by setting
the ``DEBUG`` environment variable. For example:
::
  DEBUG=http artillery run my-script.yaml

Or if you are on Windows:
::
  set DEBUG=http
  artillery run my-script.yaml

Debugging HTTP scenarios
########################

Set ``DEBUG`` to:

- ``http`` - to print requests and any errors
- ``http:response`` - to print responses
- ``http:capture`` - to print capture and transform operations

Multiple settings can be combined, for example:
::
  DEBUG=http,http:response artillery run my-script.yaml

Debugging Socket.io scenarios
#############################

Set ``DEBUG`` to:

- ``socketio`` to print errors

Debugging WebSocket scenarios
#############################

Set ``DEBUG`` to:

- ``ws`` to print errors

Create a debug profile
######################

To make troubleshooting your scenario easier, it can be useful to specify a
"debug" environment in the config section of your script that will create only
one virtual user. For example:
::

  config:
    target: "http://myapi.dev"
    environments:
      debug:
        phases:
          - duration: 5
            arrivalCount: 1
  scenarios:
    - name: "My scenario"
      flow:
        - get:
            url: "/"

Tell Artillery to use the "debug" environment with:
::
  artillery run -e debug my-script.yaml

Logging everything
##############

You can print all debug information (including debug information from
Artillery's dependencies) by setting ``DEBUG=*``
