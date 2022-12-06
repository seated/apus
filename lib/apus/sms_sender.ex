defmodule Apus.SmsSender do
  @moduledoc """
  """

  require Logger

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
    with true <- message_valid?(message) do
      case adapter.deliver(message, config) do
        {:error, error_message} = result ->
          log_delivery_failure(error_message, message, adapter)
          result

        {:ok, sent_message} ->
          log_sent(sent_message, adapter)
          sent_message
      end
    else
      {false, field} ->
        log_unsent(message, field)
        {:error, {field, "Cannot be nil or empty"}}
    end
  end

  @doc false
  def deliver_later(adapter, message, config) do
    with true <- message_valid?(message) do
      config.deliver_later_strategy.deliver_later(adapter, message, config)
      log_sent(message, adapter)
      message
    else
      {false, field} ->
        log_unsent(message, field)
        {:error, {field, "Cannot be nil or empty"}}
    end
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

  defp message_valid?(%{to: to}) when to in [nil, ""], do: {false, :to}
  defp message_valid?(%{body: body}) when body in [nil, ""], do: {false, :body}
  defp message_valid?(_), do: true

  defp log_sent(message, adapter) do
    Logger.debug("""
    Sending message with #{inspect(adapter)}:

    #{inspect(message, limit: :infinity)}
    """)
  end

  defp log_unsent(message, field) do
    Logger.debug("""
    Message was not sent because the '#{Atom.to_string(field)}' field was nil or empty.

    Attempted message: #{inspect(message, limit: :infinity)}
    """)
  end

  defp log_delivery_failure(error, message, adapter) do
    Logger.debug("""
    Failed to sending message with #{inspect(adapter)} (#{error}):

    #{inspect(message, limit: :infinity)}
    """)
  end
end
