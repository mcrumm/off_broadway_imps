defmodule OffBroadway.Imps.AsyncProducer do
  @moduledoc """
  A fully asynchronous producer.
  """
  use GenStage

  @impl GenStage
  def init(_opts) do
    {:producer, :ok}
  end

  @impl GenStage
  def handle_cast({InMemoryProducer, :enqueue, messages}, state) do
    {:noreply, messages, state}
  end

  @impl GenStage
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
