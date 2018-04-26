defmodule Apus.TaskSupervisorStrategy do
  @moduledoc """
  """

  @behaviour Apus.DeliverLaterStrategy

  @doc false
  def deliver_later(adapter, email, config) do
    Task.Supervisor.start_child(supervisor_name(), fn ->
      adapter.deliver(email, config)
    end)
  end

  def supervisor_name do
    Apus.TaskSupervisor
  end
end
