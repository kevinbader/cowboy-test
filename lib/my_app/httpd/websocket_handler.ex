defmodule MyApp.Httpd.WebsocketHandler do
  alias UUID
  alias Phoenix.Tracker
  alias Phoenix.PubSub
  alias MyApp.UserGroups.PresenceTracker, as: UserTracker

  def init(req, %{}) do
    user = :cowboy_req.binding(:userid, req)
    {:cowboy_websocket, req, %{userid: user}}
  end

  def websocket_init(state) do
    user = UUID.uuid4()  # random user name
    topic = "user:#{user}"  # each user has a dedicated topic
    key = user  # presence tracked by user id
    PubSub.subscribe(MyApp.PubSub, topic, link: true)
    Tracker.track(UserTracker, self(), topic, key, _meta = %{})
    {:reply, {:text, "HELO"}, state}
  end

  def websocket_handle({:text, text} = _frame, state) do
    # echo
    # IO.puts "got: #{inspect text}"
    reply = ~s(You said "#{text}".)
    {:reply, {:text, reply}, state, :hibernate}
  end

  def websocket_handle(frame, state) do
    IO.puts "some frame: " <> inspect(frame)
    # ignore
    {:ok, state, :hibernate}
  end

  # def websocket_info(:say_hello, state) do
  #   user_clients = UserGroups.list_clients(state.userid)
  #   msg = "Hello, #{state.userid}. Your devices: #{inspect user_clients}."
  #   {:reply, {:text, msg}, state}
  # end

  def websocket_info(:shutdown_connection, state) do
    {:stop, state}
  end

  # def websocket_info(:join_group, state) do
  #   UserGroups.add_client(state.userid)
  #   reply = "Hello #{state.userid}."
  #   # user_clients = UserGroups.list_clients(userid)
  #   # reply = "Hello #{userid}. Your devices: #{inspect user_clients}."
  #   {:reply, {:text, reply}, state, :hibernate}
  # end

  def websocket_info({:client_joined, _key, _meta}, state) do
    IO.write(:stderr, "+")
    {:ok, state}
  end

  def websocket_info({:client_left, _key, _meta}, state) do
    IO.write(:stderr, "-")
    {:ok, state}
  end

  def websocket_info(stuff, state) do
    IO.write(:stderr, inspect(stuff))
    {:ok, state}
  end

  # def websocket_info({:client_joined, _userid, pid}, state) do
  #   msg = "client joined: " <> inspect(pid)
  #   {:reply, {:text, msg}, state}
  # end

  # def websocket_info({:client_left, _userid, pid}, state) do
  #   msg = "client left: " <> inspect(pid)
  #   {:reply, {:text, msg}, state}
  # end
end
