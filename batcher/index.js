const amqp = require('amqplib/callback_api')

const exchangeName = 'rabbits'
const sourceTopic = 'orders.created'

let buffer = {}
let timers = {}
let channel

function processOrder (order) {
  const { location } = order

  if (buffer[location]) {
    buffer[location].push(order)
  } else {
    buffer[location] = [order]
    timers[location] = setTimeout(
      () => {
        console.log(` [x] buffer timed out for ${location}`)
        clearBuffer(location)
      },
      5000
    )
  }

  if (buffer[location].length >= 5) {
    console.log(` [x] buffer full for ${location}`)
    clearBuffer(location)
  }
}

function clearBuffer (location) {
  const orders = Buffer.from(
    JSON.stringify(
      buffer[location].map(o => o.id)
    )
  )

  // ... generate the pdf and store it in a common dir, so rails can attach it to a record

  clearTimeout(timers[location])
  delete timers[location]
  delete buffer[location]

  channel.publish('rabbits', 'batches.prepared', orders)
  console.log(` [x] batch ready for ${location}`)
}

amqp.connect('amqp://localhost', function(err, conn) {
  conn.createChannel(function(err, ch) {
    channel = ch

    channel.assertExchange(exchangeName, 'topic', { durable: true })
    channel.assertQueue('batcher', { durable: true }, (err, q) => {
      ch.bindQueue(q.queue, exchangeName, sourceTopic)

      channel.prefetch(1)

      console.log(" [*] Waiting for new orders. To exit press CTRL+C")

      channel.consume(
        'batcher',
        (msg) => {
          const order = JSON.parse(msg.content)
          const { commodity, quantity, location } = order

          console.log(` [x] Received an order for ${commodity} [${quantity}] from ${location}`)

          processOrder(order)

          channel.ack(msg)
        },
        { noAck: false }
      )
    })
  })
})
