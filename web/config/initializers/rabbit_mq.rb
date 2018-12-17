require 'sneakers'
require 'bunny'

# Initializers are called once per worker.
# We don't want to create too many connections, so two per worker should be enough: one for publishing and one for
# consuming.
producer_conn = Bunny.new
producer_conn.start

# Since Puma uses threads as well as workers, and Bunny channels shouldn't be shared between threads, we need
# to setup a channel pool. Pooling logic has been extracted to the EventBus interface.
EventBus.start(connection: producer_conn)
EventBus.configure_worker_queues

# Cleanup
trap('TERM') { EventBus.stop }

Sneakers.configure(exchange: 'rabbits', exchange_type: 'topic', workers: 2)
