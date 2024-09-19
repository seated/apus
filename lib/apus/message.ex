defmodule Apus.Message do
  @moduledoc """
  """

  defstruct from: nil, to: nil, body: nil, provider: nil, message_id: nil, status_callback: nil, content_sid: nil, content_variables: nil

  def new(attrs \\ []), do: struct(__MODULE__, attrs)
end
