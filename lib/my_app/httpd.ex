defmodule MyApp.Httpd do
  use GenServer

  alias MyApp.Httpd.Params
  alias MyApp.Httpd.WebsocketHandler

  defmodule IndexHandler do
    def init(req, :nostate) do
      users = Params.get(req, :users, :list)
      IO.puts("received request with users=#{inspect(users)}")
      reply = :cowboy_req.reply(200, %{"content-type" => "text/plain"}, "Hello World!\n", req)
      {:ok, reply, :nostate}
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    IO.puts("starting server")
    port = (System.get_env("PORT") || "8080") |> String.to_integer()
    dispatch = routes() |> :cowboy_router.compile()
    {:ok, server} = :cowboy.start_clear(:http, [port: port], %{env: %{dispatch: dispatch}})
    IO.puts("listening on port #{port}")
    {:ok, %{cowboy: server}}
  end

  defp routes, do: [anyhost()]

  defp anyhost do
    host_match = :_
    paths = [index_path(), socket_path()]
    {host_match, paths}
  end

  defp index_path, do: {"/", IndexHandler, :nostate}

  defp socket_path, do: {"/socket/:userid", [:nonempty], WebsocketHandler, %{}}
end