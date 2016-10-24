defmodule MyPlug do
  import Plug.Conn

  def init(options) do
    # initialize options

    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http MyPlug, []
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world !")
  end
end
