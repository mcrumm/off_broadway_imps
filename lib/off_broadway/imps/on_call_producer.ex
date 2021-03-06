defmodule OffBroadway.Imps.OnCallProducer do
  @moduledoc """
  A `Broadway` producer that replies when enqueueing messages.

  When called from the `c:Broadway.handle_batch/4` callback
  of a pipeline, this producer immediately replies to said
  call, allowing effective acknowledgement of the messages
  to continue in the calling pipeline.

  Messages will be enqueued in this pipeline until there is
  consumer demand.
  """
  use GenStage
  import OffBroadway.Imps.QueueHelpers

  @impl GenStage
  def init(_opts) do
    {:producer,
     %{
       queue: :queue.new(),
       demand: 0
     }}
  end

  @impl GenStage
  def handle_call({InMemoryProducer, :enqueue, messages}, _from, state) do
    %{demand: demand, queue: queue} = state

    # TODO: limit the queue size
    {demand, messages, queue} =
      queue
      |> enqueue_many(nil, messages)
      |> dequeue_many(demand)

    {:reply, :ok, messages, %{state | demand: demand, queue: queue}}
  end

  @impl GenStage
  def handle_demand(incoming_demand, state) do
    %{demand: demand, queue: queue} = state

    {demand, messages, queue} = dequeue_many(queue, demand + incoming_demand)

    {:noreply, messages, %{state | queue: queue, demand: demand}}
  end
end
