defmodule Apus.LocalAdapter do
  @moduledoc """
  """

  @behaviour Apus.Adapter

  alias Apus.SentMessages

  def deliver(message, _config) do
    SentMessages.push({:ok, message})
  end

  def handle_config(config), do: config
end
