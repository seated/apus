defmodule Apus.LocalAdapter do
  @moduledoc """
  Deliver messages to a local inbox, available to view if
  `Apus.SentMessagesViewerPlug` is installed in your router.
  """

  @behaviour Apus.Adapter

  alias Apus.SentMessages

  def deliver(message, _config) do
    case SentMessages.push(message) do
      :ok -> {:ok, message}
      error -> {:error, error}
    end
  end

  def handle_config(config), do: config
end
