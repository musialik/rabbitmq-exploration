# RabbitMQ demo

## How to start

in `web` lives a rails app. You know what to do (bundle, migrate, start, etc.)
in `batcher` lives a node-js script that takes orders from the web app and groups them into deliveries (npm install, npm start)
in `web` right next to the rails app, lives a rake task that will receive batches from the batcher (`WORKERS=DeliveryScheduler rake sneakers:run`)
in `rabbitmq` lives a docker-compose config for a rabbitmq node with default config (docker-compose up)

Now you can visit the rails app at `localhost:3000`
