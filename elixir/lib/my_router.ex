defmodule MyRouter do
  use Plug.Router
  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "ok")
    |> halt
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http MyRouter, []
  end

  # forward "/users", to: UsersRouter

  match _ do
    send_resp(conn, 404, "oops")
  end
end

