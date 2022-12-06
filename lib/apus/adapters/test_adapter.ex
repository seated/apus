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
    {:ok, send(self(), {:delivered_message, message})}
  end

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
