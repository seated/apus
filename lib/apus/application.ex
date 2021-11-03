defmodule Apus.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      %{id: Apus.SentMessages, start: {Apus.SentMessages, :start_link, []}},
      {Task.Supervisor, name: Apus.TaskSupervisorStrategy.supervisor_name()}
    ]

    opts = [strategy: :one_for_one, name: Apus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
