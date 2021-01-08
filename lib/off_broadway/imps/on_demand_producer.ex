defmodule OffBroadway.Imps.OnDemandProducer do
  @moduledoc """
  A `Broadway` producer that replies when dequeuing messages.

  When called from the `c:Broadway.handle_batch/4` callback
  of a pipeline, this producer will reply when the first
  message in the batch has been dispatched to a consumer,
  allowing effective acknowledgement of the messages to
  continue in the calling pipeline.

  Messages will be enqueued in this pipeline until there is
  consumer demand.
  """
  use OffBroadway.Imps.InMemoryProducer
  import OffBroadway.Imps.QueueHelpers
  alias OffBroadway.Imps.InMemoryProducer

  @impl InMemoryProducer
  def init_producer(_opts) do
    {:ok,
     %{
       queue: :queue.new(),
       demand: 0
     }}
  end

  @impl InMemoryProducer
  def handle_messages(messages, from, state) do
    %{demand: demand, queue: queue} = state

    # TODO: limit the queue size
    {demand, messages, queue} =
      queue
      |> enqueue_many(from, messages)
      |> dequeue_many(demand)

    {:noreply, messages, %{state | demand: demand, queue: queue}}
  end

  @impl GenStage
  def handle_demand(incoming_demand, state) do
    %{demand: demand, queue: queue} = state

    {demand, messages, queue} = dequeue_many(queue, demand + incoming_demand)

    {:noreply, messages, %{state | queue: queue, demand: demand}}
  end
end
