defmodule Apus.Test do
  @moduledoc """
  """

  import ExUnit.Assertions

  @doc """
  Asserts any message was delivered.

  ## Example

      iex> import Apus.Test
      iex> alias Apus.Message

      iex> message = %Message{to: 1234, body: "message body"}
      iex> Apus.TestAdapter.deliver(message, nil)

      iex> # Assert any message was sent
      iex> assert_delivered_message()
      %Apus.Message{body: "message body", from: nil, to: 1234}
  """
  def assert_delivered_message() do
    assert_receive {:delivered_message, message},
                   100,
                   Apus.Test.flunk_with_message_list("<<any message>>")

    message
  end

  @spec assert_delivered_message_matches((any -> any)) :: any
  @doc ~S"""
  Custom function matcher asserion logic.

  Allows for more flexible message matching

  ## Examples

      iex> import ExUnit.Assertions
      iex> import Apus.Test
      iex> alias Apus.Message

      iex> message = %Message{to: 1234, body: "message body with an unknown number 123"}
      iex> Apus.TestAdapter.deliver(message, nil)

      iex> # custom assertion with a matcher function
      iex> assert_delivered_message_matches(fn msg ->
      ...>   assert msg.to == 1234
      ...>   assert msg.body =~ "unknown"
      ...> end)
      %Apus.Message{body: "message body with an unknown number 123", from: nil, to: 1234}
  """
  def assert_delivered_message_matches(fun) when is_function(fun, 1) do
    assert_receive {:delivered_message, message}

    # Run custom function matcher on received message
    assert(fun.(message))

    message
  end

  @doc ~S"""
  Refutes that *any message* was delivered.

  ## Examples

      iex> refute_delivered_message()

  """
  def refute_delivered_message() do
    refute_receive {:delivered_message, message},
                   100,
                   Apus.Test.flunk_with_unexpected_message(message)
  end

  @doc """
  Asserts that a *specific message* was delivered
  """
  defmacro assert_delivered_message(message, timeout \\ 100) do
    quote do
      import ExUnit.Assertions
      message = unquote(message)

      assert_receive {:delivered_message, ^message},
                     unquote(timeout),
                     Apus.Test.flunk_with_message_list(message)
    end
  end

  @doc """
  Refutes that a *specific message* was delivered
  """
  defmacro refute_delivered_message(message, timeout \\ 100) do
    quote do
      import ExUnit.Assertions
      message = unquote(message)

      refute_receive {:delivered_message, ^message},
                     unquote(timeout),
                     Apus.Test.flunk_with_unexpected_message(message)
    end
  end

  @doc false
  def flunk_with_message_list(message) do
    case delivered_messages() do
      [] ->
        flunk("There were no messages delivered to this process.")

      messages ->
        message_list =
          messages
          |> Enum.map(&"  * #{inspect(&1)}")
          |> Enum.join("\n")

        flunk("""
        There were no matching messages delivered to this process.

        Expected to match:

          #{inspect(message)}

        Delivered messages:

        #{message_list}
        """)
    end
  end

  @doc false
  def flunk_with_unexpected_message(message) do
    flunk("""
    A message was unexpectedly delivered.

    Delivered message:

      #{inspect(message)}
    """)
  end

  defp delivered_messages() do
    {:messages, messages} = Process.info(self(), :messages)

    for {:delivered_message, _} = message <- messages, do: message
  end
end
