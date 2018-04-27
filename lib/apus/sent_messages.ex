defmodule Apus.SentMessages do
  @moduledoc false

  def start_link() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def all() do
    Agent.get(__MODULE__, fn messages -> messages end)
  end

  def push(message) do
    Agent.update(__MODULE__, fn messages ->
      [message | messages]
    end)

    message
  end
end
