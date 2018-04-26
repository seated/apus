defmodule Apus.Test do
  @moduledoc """
  """

  import ExUnit.Assertions

  defmacro assert_delivered_message(message, timeout \\ 100) do
    quote do
      import ExUnit.Assertions
      message = unquote(message)

      assert_receive {:delivered_message, ^message},
                     unquote(timeout),
                     Apus.Test.flunk_with_message_list(message)
    end
  end

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
