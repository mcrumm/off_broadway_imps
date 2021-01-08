defmodule OffBroadway.Imps.OnCallProducerTest do
  use ExUnit.Case, async: true

  alias OffBroadway.Imps.InMemoryProducer
  alias OffBroadway.Imps.OnCallProducer
  alias Broadway.CallerAcknowledger
  alias Broadway.Message

  defmodule Noops do
    use Broadway
    def handle_message(_, message, _), do: message
    def handle_batch(_, messages, _, _), do: messages
  end

  describe "loading in" do
    setup do
      test_pid = self()

      broadway_name = new_unique_name()

      {:ok, broadway} =
        Broadway.start_link(Noops,
          name: broadway_name,
          context: %{test_pid: self()},
          producer: [module: {OnCallProducer, []}],
          processors: [default: [concurrency: 1]],
          batchers: [default: [concurrency: 1, batch_size: 2, batch_timeout: 50]]
        )

      %{
        broadway: broadway,
        broadway_name: broadway_name,
        producer_name: get_producer(broadway_name),
        test_pid: test_pid
      }
    end

    test "enqueue replies immediately", %{producer_name: producer_name} do
      assert GenStage.call(
               producer_name,
               {InMemoryProducer, :enqueue, wrap_messages([1, 2, 3], ref = make_ref())},
               50
             ) == :ok

      assert_receive {:ack, ^ref, [%{data: 1}, %{data: 2}], []}
      assert_receive {:ack, ^ref, [%{data: 3}], []}
    end
  end

  defp new_unique_name do
    :"Elixir.OffBroadway.Imps#{System.unique_integer([:positive, :monotonic])}"
  end

  defp get_producer(broadway_name, index \\ 0) do
    :"#{broadway_name}.Broadway.Producer_#{index}"
  end

  defp wrap_messages(list, ack_ref) do
    ack = {CallerAcknowledger, {self(), ack_ref}, :ok}
    Enum.map(list, &%Message{data: &1, acknowledger: ack})
  end
end
