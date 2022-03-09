defmodule Bex.Binance.Stream.Price do
  use WebSockex
  require Logger

  @stream_endpoint "wss://stream.binance.com:9443/ws/"

  def start_link(symbol, state \\ []) do
    WebSockex.start_link(
      "#{@stream_endpoint}#{symbol}@trade",
      __MODULE__,
      state
    )
  end

  def handle_frame({type, msg}, state) do
    # IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}")

    case Jason.decode(msg) do
      {:ok, %{"s" => symbol} = message} ->
        symbol
        |> String.downcase()
        |> prepend_channel()
        |> BexWeb.Endpoint.broadcast!("price_change", message)

      {:error, error} ->
        Logger.error(error)
    end

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.info("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  defp prepend_channel(symbol) do
    "futures:lobby:" <> symbol
  end
end
