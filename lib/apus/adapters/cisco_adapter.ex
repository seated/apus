defmodule Apus.CiscoAdapter do
  @moduledoc """
  """

  @behaviour Apus.Adapter

  @messages_url "https://api.us.webexconnect.io/v2/messages"

  def deliver(message, config) do
    params = message |> convert_to_cisco_params() |> Jason.encode!()

    case :hackney.post(@messages_url, headers(config), params, []) do
      {:ok, 401, _headers, _response} ->
        {:error, "Unauthorized"}

      {:ok, status, _headers, response} when status > 299 ->
        {:ok, body} = :hackney.body(response)
        body = Jason.decode!(body)
        {:error, body["message"]}

      {:ok, _status, _headers, response} ->
        {:ok, body} = :hackney.body(response)
        body = Jason.decode!(body)

        message = %Apus.Message{
          from: message.from,
          to: message.to,
          body: message.body,
          provider: "cisco",
          message_id: body["messageId"]
        }

        {:ok, message}

      error ->
        error
    end
  end

  def handle_config(config), do: config

  defp convert_to_cisco_params(message) do
    %{
      channel: "sms",
      from: message.from,
      to: build_to_param(message.to),
      content: %{type: "text", text: message.body}
    }
  end

  defp build_to_param(to_number) do
    [
      %{msisdn: [to_number]}
    ]
  end

  defp headers(config) do
    [
      key: config.service_key,
      "Content-Type": "application/json",
      Accept: "application/json"
    ]
  end
end
