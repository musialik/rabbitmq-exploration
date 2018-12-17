class EventBus
  # These values could be extracted to .env in a real app
  CHANNEL_POOL_SIZE = 5 # These many channels will be shared between Puma/Sneakers threads
  CHANNEL_POOL_TIMEOUT = 5

  # Stores the provided Bunny connection and sets up a channel pool
  def self.start
    @conn = Bunny.new
    @conn.start
    @pool = ConnectionPool.new(size: CHANNEL_POOL_SIZE, timeout: CHANNEL_POOL_TIMEOUT) { conn.create_channel }
    @pool.with { |channel| channel.topic('rabbits', durable: true) }
  end

  # If I understand it correctly, this connection will be shared between threads in a worker. So each puma worker
  # will have one connection and threads will use channels from a pool. Which is exactly what we need.
  def self.conn
    @conn
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
    conn.close if conn
  end

  def self.pool
    start unless @pool
    @pool
  end

  # def self.event(name,  &block)
  #   define_method name, &block
  #
  #   class_eval do
  #     define_method name do |*args|
  #       pool.with { |channel| new(channel).send(name, *args) }
  #     end
  #   end
  # end

  def self.order_created(order)
    pool.with { |channel| new(channel).order_created(order) }
  end

  def self.order_updated(order)
    pool.with { |channel| new(channel).order_updated(order) }
  end

  def self.delivery_created(delivery)
    pool.with { |channel| new(channel).delivery_created(order) }
  end

  # Instance api

  attr_reader :channel

  # If you have an open channel, you can use it instead of openning new connections.
  def initialize(channel)
    @channel = channel
  end

  def order_created(order)
    exchange = @channel.topic('rabbits')
    exchange.publish(order.to_json, routing_key: 'orders.created')
  end

  def order_updated(order)
    exchange = @channel.topic('rabbits')
    exchange.publish(order.to_json, routing_key: 'orders.updated')
  end

  def delivery_created(delivery)
    exchange = channel.topic('rabbits')
    exchange.publish(delivery.to_json, routing_key: 'deliveries.created')
  end
end
