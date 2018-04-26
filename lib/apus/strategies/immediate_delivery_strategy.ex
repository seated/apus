defmodule Apus.ImmediateDeliveryStrategy do
  @moduledoc """
  """

  @behaviour Apus.DeliverLaterStrategy

  @doc false
  def deliver_later(adapter, message, config) do
    adapter.deliver(message, config)
  end
end
