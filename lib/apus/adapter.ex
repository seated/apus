defmodule Apus.Adapter do
  @moduledoc """
  An adapter provides a way to communicate with a third-party SMS service
  using a consistent API.
  """

  @doc "Send the SMS message."
  @callback deliver(%Apus.Message{}, config :: map) :: {:ok, Apus.Message.t()} | {:error, any}

  @doc "Initialize adapter configuration."
  @callback handle_config(config :: map) :: config :: map
end
