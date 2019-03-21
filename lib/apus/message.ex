defmodule Apus.Message do
  @moduledoc """
  """

  defstruct sid: nil, from: nil, to: nil, body: nil

  def new(attrs \\ []), do: struct(__MODULE__, attrs)
end
