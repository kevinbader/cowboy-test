defmodule MyApp.Application do
  @moduledoc false

  use Application

  alias MyApp.Httpd
  alias MyApp.Sender
  #alias MyApp.UserGroups.Syn, as: UserGroups
  alias MyApp.UserGroups.PresenceTracker, as: UserTracker
  alias MyApp.PresenceServer

  def start(_type, _args) do
    connect_nodes()
    import Supervisor.Spec, warn: false
    #UserGroups.init()

    children = [
      Httpd,
      #Sender,
      supervisor(Phoenix.PubSub.PG2, [MyApp.PubSub, []]),
      worker(UserTracker, [[name: UserTracker, pubsub_server: MyApp.PubSub]]),
      PresenceServer,
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp connect_nodes do
    case System.get_env("NODES") do
      nil -> nil
      "" -> nil
      nodes ->
        nodes
        |> String.split(",")
        |> Enum.each(fn sname -> Node.connect(:"#{sname}@127.0.0.1") end)
    end
  end
end
