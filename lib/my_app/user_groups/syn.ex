defmodule MyApp.UserGroups.Syn do
  def init do
    :syn.init()
  end

  def add_client(userid) do
    pid = self()

    :ok =
      userid
      |> userid_to_groupname()
      |> :syn.join_lazily(pid)

    broadcast(userid, {:client_joined, userid, pid})
  end

  def list_clients(userid) do
    userid
    |> userid_to_groupname()
    |> :syn.get_members()
  end

  def broadcast(userid, msg) do
    userid
    |> userid_to_groupname()
    |> :syn.publish(msg)
  end

  # callbacks

  def process_exit_callback(name, pid, _meta, _reason) do
    userid = groupname_to_userid(name)
    broadcast(userid, {:client_left, userid, pid})
  end

  # private

  defp userid_to_groupname(userid), do: "users:#{userid}"

  defp groupname_to_userid("users:" <> userid), do: userid
end