defmodule Apus.PlivoAdapter do
  @moduledoc """
  """

  @behaviour Apus.Adapter

  def deliver(message, config) do
    params = convert_to_plivo_params(message)

    case :hackney.post(uri(config), headers(config), params, options(config)) do
      {:ok, status, _headers, response} when status > 299 ->
        {:ok, body} = :hackney.body(response)
        {:ok, body} = Jason.decode(body)
        {:error, body["error"]}

      {:ok, _status, _headers, _response} ->
        {:ok, message}

      error ->
        error
    end
  end

  def handle_config(config), do: config

  defp uri(config) do
    "https://api.plivo.com/v1/Account/#{config.auth_id}/Message/"
  end

  defp headers(config) do
    auth = Base.encode64("#{config.auth_id}:#{config.auth_token}")

    [
      Authorization: "Basic #{auth}",
      "Content-Type": "application/json"
    ]
  end

  defp convert_to_plivo_params(message) do
    %{
      src: message.from,
      dst: message.to,
      text: message.body
    }
    |> Jason.encode!()
  end

  defp options(config) do
    config[:request_options] || []
  end
end
