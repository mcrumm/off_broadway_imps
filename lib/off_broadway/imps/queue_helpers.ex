defmodule OffBroadway.Imps.QueueHelpers do
  @moduledoc false

  def enqueue_many(queue, _from, []), do: queue
  def enqueue_many(queue, from, list), do: :queue.in({from, list}, queue)

  def dequeue_many(queue, demand), do: dequeue_many(queue, demand, [])

  defp dequeue_many(queue, 0, acc) do
    {0, Enum.reverse(acc), queue}
  end

  defp dequeue_many(queue, demand, acc) do
    case :queue.out(queue) do
      {{:value, {from, list}}, queue} ->
        from && GenServer.reply(from, :ok)

        case reverse_split_demand(list, demand, acc) do
          {0, acc, rest} when rest != [] ->
            {0, Enum.reverse(acc), :queue.in_r({nil, rest}, queue)}

          {demand, acc, []} ->
            dequeue_many(queue, demand, acc)
        end

      {:empty, queue} ->
        {demand, Enum.reverse(acc), queue}
    end
  end

  defp reverse_split_demand(rest, 0, acc) do
    {0, acc, rest}
  end

  defp reverse_split_demand([], demand, acc) do
    {demand, acc, []}
  end

  defp reverse_split_demand([head | tail], demand, acc) do
    reverse_split_demand(tail, demand - 1, [head | acc])
  end
end
