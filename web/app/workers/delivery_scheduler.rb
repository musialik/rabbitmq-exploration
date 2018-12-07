class DeliveryScheduler
  include Sneakers::Worker
  from_queue :orders,
    timeout_job_after: 15,
    prefetch: 1,
    durable: true,
    ack: true

  def work(order)
    hash = JSON.parse(order)
    order = Order.find(hash['id'])
    order.update!(ack: true)

    sleep 5

    Order.transaction do
      delivery = Delivery.create!
      order.update!(delivery: delivery)
      ack!
    end
  end
end
