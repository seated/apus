defmodule Apus.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Apus.SentMessages, []),
      {Task.Supervisor, name: Apus.TaskSupervisorStrategy.supervisor_name()}
    ]

    opts = [strategy: :one_for_one, name: Apus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
