require 'sneakers'
require 'bunny'

# Since Puma uses threads as well as workers, and Bunny channels shouldn't be shared between threads, we need
# to setup a channel pool. Pooling logic has been extracted to the EventBus interface.
EventBus.start
EventBus.configure_worker_queues

# Cleanup
# trap('TERM') { EventBus.stop }

Sneakers.configure(exchange: 'rabbits', exchange_type: 'topic')
