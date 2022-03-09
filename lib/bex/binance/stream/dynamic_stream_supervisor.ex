defmodule Bex.Binance.Stream.DynamicStreamSupervisor do
  use DynamicSupervisor
  alias Bex.Binance.Stream.Price
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_worker(symbol) do
    Logger.info("Starting streaming #{symbol} Price data")
    start_child(symbol)
  end

  defp start_child(args) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Price, args}
    )
  end
end
