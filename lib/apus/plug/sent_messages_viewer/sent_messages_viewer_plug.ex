defmodule Apus.SentMessagesViewerPlug do
  use Plug.Router

  require EEx

  alias Apus.SentMessages

  index_template = Path.join(__DIR__, "index.html.eex")
  EEx.function_from_file(:defp, :index, index_template, [:assigns])

  no_messages_template = Path.join(__DIR__, "no_messages.html.eex")
  EEx.function_from_file(:defp, :no_messages, no_messages_template)

  plug(:match)
  plug(:dispatch)

  get "/" do
    messages = SentMessages.all()
    render_index(conn, messages)
  end

  defp render_index(conn, []) do
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> send_resp(:ok, no_messages())
  end

  defp render_index(conn, messages) do
    assigns = %{
      conn: conn,
      messages: messages
    }

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> send_resp(:ok, index(assigns))
  end
end
