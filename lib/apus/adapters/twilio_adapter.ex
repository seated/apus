defmodule Apus.TwilioAdapter do
  @moduledoc """
  """

  @behaviour Apus.Adapter

  def deliver(message, config) do
    params = message |> convert_to_twilio_params(config) |> to_query_string()

    case :hackney.post(uri(config), headers(config), params, options(config)) do
      {:ok, status, _headers, response} when status > 299 ->
        {:ok, body} = :hackney.body(response)
        body = Jason.decode!(body)
        {:error, body["message"]}

      {:ok, _status, _headers, response} ->
        {:ok, body} = :hackney.body(response)
        body = Jason.decode!(body)

        message = %Apus.Message{
          from: body["from"],
          to: body["to"],
          body: body["body"],
          provider: "twilio",
          message_id: body["sid"]
        }

        {:ok, message}

      error ->
        error
    end
  end

  def handle_config(config), do: config

  defp uri(config) do
    "https://api.twilio.com/2010-04-01/Accounts/#{config.account_sid}/Messages.json"
  end

  defp headers(config) do
    auth = Base.encode64("#{config.account_sid}:#{config.auth_token}")

    [
      Authorization: "Basic #{auth}",
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
    ]
  end

  defp convert_to_twilio_params(message, config) do
    message
    |> Map.from_struct()
    |> maybe_put_service_sid(config)
    |> remove_provider_and_message_id()
    |> maybe_remove_status_callback()
    |> maybe_remove_content_sid()
    |> maybe_remove_content_variables()
    |> Map.to_list()
  end

  defp to_query_string(list) do
    list
    |> Enum.flat_map(fn {key, value} ->
      [{camelize(key), process_value(value)}]
    end)
    |> URI.encode_query()
  end

  defp process_value(value) do
    # content_variables will be a map and we need to convert it to a string
    if is_map(value) do
      Jason.encode!(value)
    else
      value
    end
  end

  defp camelize(name) do
    name |> to_string |> Macro.camelize()
  end

  defp maybe_put_service_sid(%{from: from} = message, %{messaging_service_sid: sid})
       when from in [nil, ""] do
    Map.put(message, :messaging_service_sid, sid)
  end

  defp maybe_put_service_sid(message, _config), do: message

  defp remove_provider_and_message_id(message) do
    Map.drop(message, [:provider, :message_id])
  end

  defp maybe_remove_status_callback(%{status_callback: nil} = message) do
    Map.drop(message, [:status_callback])
  end

  defp maybe_remove_status_callback(%{status_callback: _status_callback} = message), do: message

  defp maybe_remove_content_sid(%{content_sid: nil} = message) do
    Map.drop(message, [:content_sid])
  end

  defp maybe_remove_content_sid(%{content_sid: _content_sid} = message), do: message

  defp maybe_remove_content_variables(%{content_variables: nil} = message) do
    Map.drop(message, [:content_variables])
  end

  defp maybe_remove_content_variables(%{content_variables: _content_variables} = message), do: message

  defp options(config) do
    config[:request_options] || []
  end
end
