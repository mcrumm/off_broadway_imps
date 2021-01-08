defmodule OffBroadway.Imps.InMemoryProducer do
  @moduledoc """
  An `InMemoryProducer` receives and dispatches local messages.

  Generally speaking, an in-memory producer will receive its
  messages from the `c:Broadway.handle_batch/4` callback
  of another pipeline. This allows pipelines to be chained
  together to handle more complex message routing scenarios.
  """
  alias Broadway.Message

  @typedoc "A `Broadway.Message`"
  @type message :: Message.t()

  @typedoc "A list of `Broadway.Message`s."
  @type messages :: [message, ...]

  @doc """
  Initializes the in-memory producer.
  """
  @callback init_producer(producer_opts :: any) ::
              {:ok, state :: term} | {:error, reason :: String.t()}

  @doc """
  Handle incoming `Broadway.Message`s.
  """
  @callback handle_messages(messages, state :: term) ::
              {:noreply, [message], new_state}
              | {:noreply, [message], new_state, :hibernate}
              | {:stop, reason :: term, new_state}
            when new_state: term

  @doc """
  Handle incoming `Broadway.Message`s.
  """
  @callback handle_messages(messages, from :: GenServer.from(), state :: term) ::
              {:reply, reply, [message], new_state}
              | {:reply, reply, [message], new_state, :hibernate}
              | {:noreply, [message], new_state}
              | {:noreply, [message], new_state, :hibernate}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term, new_state: term, reason: term

  @optional_callbacks [init_producer: 1, handle_messages: 3]

  @doc """
  Uses InMemoryProducer in the current module to mark it
  an InMemoryProducer.

      use OffBroadway.Imps.InMemoryProducer, async: false

  ## Options

    * `:async` - Optional. Whether or not this producer is
      fully asynchronous. Default is `false`.

  """
  defmacro __using__(tags) do
    quote bind_quoted: [im_producer: __MODULE__, tags: tags] do
      use GenStage
      @behaviour Broadway.Producer
      @behaviour im_producer

      @impl GenStage
      def init(opts) do
        OffBroadway.Imps.InMemoryProducer.init(__MODULE__, opts)
      end

      @impl im_producer
      def init_producer(opts), do: {:ok, opts}

      @impl im_producer
      def handle_messages(messages, state), do: {:noreply, messages, state}

      @impl GenStage
      def handle_cast({im_producer, :enqueue, messages}, state) do
        __MODULE__.handle_messages(messages, state)
      end

      unless tags[:async] do
        @impl GenStage
        def handle_call({im_producer, :enqueue, messages}, from, state) do
          __MODULE__.handle_messages(messages, from, state)
        end
      end

      defoverridable init_producer: 1, handle_messages: 2
    end
  end

  @doc false
  def init(module, init_opts) do
    # TODO: handle gen_stage buffer options
    case module.init_producer(init_opts) do
      {:ok, state} ->
        {:producer, state}

      {:error, reason} ->
        raise ArgumentError, "#{inspect(module)} failed to start, reason: #{reason}"
    end
  end
end
