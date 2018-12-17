class EventBus
  # These values could be extracted to .env in a real app
  CHANNEL_POOL_SIZE = 5 # These many channels will be shared between Puma/Sneakers threads
  CHANNEL_POOL_TIMEOUT = 5

  # Stores the provided Bunny connection and sets up a channel pool
  def self.start(connection:)
    @conn = connection
    @pool = ConnectionPool.new(size: CHANNEL_POOL_SIZE, timeout: CHANNEL_POOL_TIMEOUT) { connection.create_channel }
    @pool.with { |channel| channel.topic('rabbits', durable: true) }
  end

  # One place to bind worker queues to the right topics
  def self.configure_worker_queues
    @pool.with do |channel|
      exchange = channel.topic('rabbits', durable: true)
      queue = channel.queue('web.delivery_scheduler', durable: true)
      queue.bind(exchange, routing_key: 'batches.prepared')
    end
  end

  def self.stop
    @conn.close
  end

  def self.pool
    @pool
  end

  def self.order_created(order)
    pool.with do |channel|
      exchange = channel.topic('rabbits')
      exchange.publish(order.to_json, routing_key: 'orders.created')
    end
  end
end
