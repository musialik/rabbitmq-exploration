# RabbitMQ demo

A demo application built from (micro)services communicating over RabbitMQ.

## What does it do?

Currently there's one view that allows you to create orders (for example: order 10 pens to office). These orders are then listed on the same view. After an order is created it's handled by a buffer, that groups similar orders together.
Right now it waits until 5 seconds have passed or until there are 5 orders for the same location.

## How to start

```
docker-compose up
```

Now you can visit the rails app at `localhost:3000`

before starting again
```
docker-compose down -v
```
