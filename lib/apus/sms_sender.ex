defmodule Apus.SmsSender do
  @moduledoc """
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      def deliver_now(message) do
        config = build_config()
        Apus.SmsSender.deliver_now(config.adapter, message, config)
      end

      def deliver_later(message) do
        config = build_config()
        Apus.SmsSender.deliver_later(config.adapter, message, config)
      end

      otp_app = Keyword.fetch!(opts, :otp_app)

      defp build_config, do: Apus.SmsSender.build_config(__MODULE__, unquote(otp_app))
    end
  end

  @doc false
  def deliver_now(adapter, message, config) do
    if message_valid?(message) do
      adapter.deliver(message, config)
    end

    message
  end

  @doc false
  def deliver_later(adapter, message, config) do
    if message_valid?(message) do
      config.deliver_later_strategy.deliver_later(adapter, message, config)
    end

    message
  end

  @doc false
  def build_config(sms_sender, otp_app) do
    otp_app
    |> Application.fetch_env!(sms_sender)
    |> Map.new()
    |> handle_adapter_config()
  end

  defp handle_adapter_config(%{adapter: adapter} = config) do
    config
    |> adapter.handle_config()
    |> Map.put_new(:deliver_later_strategy, Apus.TaskSupervisorStrategy)
  end

  defp message_valid?(%{to: to}) when to in [nil, ""], do: false
  defp message_valid?(%{body: body}) when body in [nil, ""], do: false
  defp message_valid?(_), do: true
end
