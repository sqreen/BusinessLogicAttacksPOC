# Prevent business logic attacks using dynamic instrumentation

## What is this?

This project's purpose is to illustrate the way application's business logic can be monitored and protected.

The concept was presented in the OWASP AppSec US 2018 talk [Prevent business logic attacks using dynamic instrumentation](https://appsecus2018.sched.com/event/F031).

This is a proof of concept for a server meant to monitor business event
received from open source applications and is not meant to be used in production.

It allows to trigger a webhook if specific events reach a threshold over a
period of time. 

This can be configured in this way::


    alerts:
     token_generation:
       threshold: 10
       slot: 300 # 5 minutes
     reset_password:
       threshold: 3
       slot: 60 # 1 minute
       
    webhook: http://127.0.0.1:4567/alert_triggered/


## Server

The local directory should contains `config.yml`.

The server can be run in this way::

    cd server
    bundle 
    ./main.rb /path/to/config.yml

The server will also manage to receive the alert's webhooks.

## Client

The client library need to send data to the server following this format:

    curl http://localhost:4567/event --data '{"ip": 1.2.3.4, "event_name": "my_event", "time": "2018-10-06 18:52:52 -0700"}'

An example Ruby class is provided in sdk/ruby/client.rb to be used either as a
library, either as a standalone client.


## Can I use this in production?

No. If you are looking for a production ready solution, take a look at [Sqreen](https://www.sqreen.io).

