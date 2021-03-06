defmodule Vessel.Relay do
  @moduledoc """
  This module acts as a relay IO stream to allow redirection of pairs written by
  Vessel. This is mainly provided for in-application MapReduce and for testing.

  The concept behind this module is quite simply a buffer of the messages which
  have been received from the IO stream. There are a few utility functions which
  allow you to act on the buffer, or flush it entirely.

  An example usage of this module is to start the Relay and pass the process id
  through to the `stdout/stderr` options inside the `consume/1` callback of a
  Vessel mapper or reducer. The output messages will then be received by Relay
  and can be easily used to test your components from inside unit tests.
  """
  use GenServer

  # add alias, IO is taken
  alias Vessel.IO, as: Vio

  # define process type
  @type server :: GenServer.server

  @doc """
  Creates a new Relay worker.

  Workers are always linked to the current process, as they're designed to be used
  from within ExUnit and be short lived (to avoid leaking).
  """
  @spec create(Keyword.t) :: GenServer.on_start
  def create(opts \\ []),
    do: GenServer.start_link(__MODULE__, [], opts)

  @doc """
  Flushes the Relay buffer.

  This simply throws away the current buffer stored in the Relay. No other actions
  will remove from the currently stored buffer, nor is there a way to modify the
  stored buffer.
  """
  @spec flush(server) :: :ok
  def flush(pid),
    do: GenServer.call(pid, { :relay, :flush })

  @doc """
  Forwards the entire Relay buffer to a process.

  This is to aid in testing so you may simple use receive assertions. This will
  simply send a Tuple message per buffer element (in order of reception) of the
  form `{ :relay, msg }`.
  """
  @spec forward(server, server) :: :ok
  def forward(pid, ref \\ self()),
    do: pid |> get |> Enum.each(&send(ref, { :relay, &1 }))

  @doc """
  Retrieves the ordered Relay buffer.

  This pulls back the raw buffer from the Relay and reverses it, to ensure that
  messages are correctly ordered.
  """
  @spec get(server) :: [ binary ]
  def get(pid),
    do: pid |> raw |> Enum.reverse

  @doc """
  Retrieves the raw Relay buffer.

  This is return in a reversed order, if you want the correctly ordered buffer,
  please use `Vessel.Relay.get/1`.
  """
  @spec raw(server) :: [ binary ]
  def raw(pid),
    do: GenServer.call(pid, { :relay, :raw })

  @doc """
  Retrieves a sorted Relay buffer.

  The sort here has a default of a default Hadoop sort but can be overridden to
  sort based on custom options (for example if you tweak Hadoop's sorting).

  For now you have to write your own sorting if you're doing a custom sort, as I
  have neither the time or effort to implement a GNU-like sort parser.
  """
  @spec sort(server, ((binary, binary) -> integer)) :: [ binary ]
  def sort(pid, comparator \\ &default_sort/2),
    do: pid |> raw |> Enum.sort(comparator)

  @doc """
  Stops a Relay worker.

  This just terminates an existing Relay process using `GenServer.stop/1`. It's
  just a shorthand to mask the implementation details from the user.
  """
  @spec stop(server) :: :ok
  def stop(pid),
    do: GenServer.stop(pid)

  @doc false
  # Responds to a call to flush the existing buffer. We do this just by ignoring
  # the existing state and simply setting an empty list as the new buffer.
  def handle_call({ :relay, :flush }, _ctx, _buffer),
    do: { :reply, :ok, [] }

  @doc false
  # Retrieves the raw buffer from the server, without doing any modification. We
  # don't even sort the output in case it's a large buffer which could potentially
  # block the server process to other messages coming in.
  def handle_call({ :relay, :raw }, _ctx, buffer),
    do: { :reply, buffer, buffer }

  @doc false
  # Handles both multi and single IO requests per the IO protocol. The protocol
  # actually dictates that we respond after processing, but we can guarantee that
  # we're going to accept and we don't want to block the caller any longer than
  # have to, so we acknowledge instantly.
  def handle_info({ :io_request, caller, ref, request }, buffer) do
    # acknowledge the IO call, per the protocol
    send(caller, { :io_reply, ref, :ok })

    # reduce the requests into our buffer
    new_buffer =
      request
      |> wrap_request
      |> Enum.reduce(buffer, &prep_buffer/2)

    # store the new buffer of messages
    { :noreply, new_buffer }
  end

  # Sorts two values by splitting them and comparing the keys based on natural
  # ordering, per the standard Hadoop sorting method.
  defp default_sort(left, right) do
    { lkey, _lval } = Vio.split(left,  "\t", 1)
    { rkey, _rval } = Vio.split(right, "\t", 1)
      rkey > lkey
  end

  # Just prepends a received message to the provided buffer. This is trivial but
  # is factored out just because it makes the matching more convenient to do it
  # in the function head.
  defp prep_buffer({ _put_chars, _encoding, msg }, buf),
    do: [ msg | buf ]

  # Wraps an IO request into a List, using the message itself as a hint. We use
  # this to guarantee a payload of requests we can operate on as a List which
  # opens up the ability to use any of the Enum functions against them. Note
  # that the `List.wrap/1` call should not be necessary (per the IO protocol),
  # but we do it anyway to just be safe as it should be almost instant negation.
  defp wrap_request({ :requests, requests }),
    do: requests
  defp wrap_request(request),
    do: List.wrap(request)

end
