defmodule Apus.TestAdapter do
  @moduledoc """
  """

  @behaviour Apus.Adapter

  alias Apus.ImmediateDeliveryStrategy

  def deliver(%{to: "invalid" <> _ = message}, _config) do
    {:error, message}
  end

  def deliver(%{from: "invalid" <> _ = message}, _config) do
    {:error, message}
  end

  def deliver(message, _config) do
    sent_message = Map.put(message, :message_id, "SM123")

    send(self(), {:delivered_message, sent_message})

    sent_message = update_body(sent_message)
    {:ok, sent_message}
  end

  # Mimic the behavior of the Twilio adapter when the body is not present and
  # content_variables are used. If the body is not present, Apus returns an empty string.
  defp update_body(%{body: nil, content_variables: content_variables} = message)
       when is_map(content_variables) do
    Map.put(message, :body, "")
  end

  defp update_body(message), do: message

  def handle_config(config) do
    case Map.get(config, :deliver_later_strategy) do
      nil ->
        Map.put(config, :deliver_later_strategy, ImmediateDeliveryStrategy)

      ImmediateDeliveryStrategy ->
        config

      _ ->
        raise ArgumentError, """
        Apus.TestAdapter requires that the deliver_later_strategy is
        Apus.ImmediateDeliveryStrategy

        Instead it got: #{inspect(config[:deliver_later_strategy])}
        """
    end
  end
end
