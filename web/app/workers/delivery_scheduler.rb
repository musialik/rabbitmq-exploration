class DeliveryScheduler
  include Sneakers::Worker

  from_queue 'web.delivery_scheduler',
    timeout_job_after: 15,
    threads: 5,
    prefetch: 1,
    durable: true,
    ack: true

  def work(ids)
    orders = Order.where(id: JSON.parse(ids))

    Order.transaction do
      delivery = Delivery.create!
      orders.update_all(delivery_id: delivery.id)
      ack!
    end
  end
end
