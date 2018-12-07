class Rabbit
  def self.publish(message)
    connection = Bunny.new
    connection.start

    channel = connection.create_channel
    queue = channel.queue('orders', durable: true)

    queue.publish(message.to_json, persistent: true)

    connection.close
  end
end
