class DeliveryScheduler
  include Sneakers::Worker

  from_queue 'web.delivery_scheduler',
    timeout_job_after: 5,
    threads: 1,
    prefetch: 1,
    durable: true,
    ack: true

  def work(ids)
    orders = Order.where(id: JSON.parse(ids))

    Order.transaction do
      delivery = Delivery.create!
      orders.update_all(delivery_id: delivery.id)
      after_work!(delivery)
    end

    ack!
  end

  def after_work!(delivery)
    @event_bus ||= EventBus.new(@queue.channel)
    @event_bus.delivery_created(delivery.reload)
    delivery.orders.each { |order| @event_bus.order_updated(order) }
  end
end
