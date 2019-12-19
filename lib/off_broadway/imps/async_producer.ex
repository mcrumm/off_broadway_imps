defmodule OffBroadway.Imps.AsyncProducer do
  @moduledoc """
  A fully asynchronous producer.
  """
  use OffBroadway.Imps.InMemoryProducer, async: true
  alias OffBroadway.Imps.InMemoryProducer

  @impl InMemoryProducer
  def init_producer(_opts), do: {:ok, nil}

  @impl GenStage
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
