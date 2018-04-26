defmodule Apus.Message do
  @moduledoc """
  """

  defstruct from: nil, to: nil, body: nil

  def new(attrs \\ []), do: struct(__MODULE__, attrs)
end
