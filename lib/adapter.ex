defmodule Apus.Adapter do
  @moduledoc """
  """

  @callback deliver(%Apus.Message{}, %{}) :: any
  @callback handle_config(map) :: map
end
