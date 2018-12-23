defmodule Pusher.Subscriber do
  use GenServer
  require Logger

  @exchange "rabbits"

  def start_link(_) do
    IO.puts("heheheheh\n\nfrewf")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    state =
      %{}
      |> init_connection()
      |> init_channel()
      |> init_exchange()
      |> init_queue()

    IO.inspect(state)
    AMQP.Basic.consume(state.channel, state.queue, nil, no_ack: true)

    {:ok, state}
  end

  defp init_connection(%{} = state) do
    case AMQP.Connection.open(System.get_env("RABBITMQ_URL")) do
      {:error, :econnrefused} ->
        IO.puts("Rabbit connection failed. Retrying in 5s")
        :timer.sleep(5000)
        init_connection(state)
      {:ok, connection} ->
        Map.put(state, :connection, connection)
    end
  end

  defp init_channel(%{connection: connection} = state) do
    {:ok, channel} = AMQP.Channel.open(connection)
    Map.put(state, :channel, channel)
  end

  defp init_exchange(%{channel: channel} = state) do
    :ok = AMQP.Exchange.declare(channel, @exchange, :topic, durable: true)
    state
  end

  defp init_queue(%{channel: channel} = state) do
    {:ok, %{queue: queue}} = AMQP.Queue.declare(channel, "", exclusive: true)
    :ok = AMQP.Queue.bind(channel, queue, @exchange, routing_key: "#")
    Map.put(state, :queue, queue)
  end

  def handle_info({:basic_consume_ok, _}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, json_payload, %{routing_key: routing_key} = meta}, state) do
    payload = Jason.decode!(json_payload)

    case routing_key do
      "orders." <> _ = topic ->
        Logger.info("Forwarding #{topic} #{inspect(payload)}")
        PusherWeb.Endpoint.broadcast("orders", topic, payload)

      "deliveries." <> _ = topic ->
        Logger.info("Forwarding #{topic} #{inspect(payload)}")
        PusherWeb.Endpoint.broadcast("deliveries", topic, payload)

      _ ->
        Logger.info(
          [
            "[*] ",
            routing_key,
            " => ",
            inspect(payload, charlists: :as_lists)
          ]
          |> Enum.join("")
        )
    end

    {:noreply, state}
  end

  def terminate(_, %{connection: connection}) do
    AMQP.Connection.close(connection)
  end

  def terminate(_, _) do
  end
end
