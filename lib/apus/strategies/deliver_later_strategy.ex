defmodule Apus.DeliverLaterStrategy do
  @moduledoc """
  """

  @callback deliver_later(atom, %Apus.Message{}, map) :: any
end
