defmodule MyApp.Sender do
  use GenServer

  alias MyApp.UserGroups

  def start_link(opts), do: GenServer.start_link(__MODULE__, :ok, opts)

  def init(:ok) do
    Process.send_after(self(), :say_hello_to_all_clients, 1_000)
    {:ok, %{}}
  end

  def handle_info(:say_hello_to_all_clients, state) do
    for userid <- ["foo", "bar"] do
      UserGroups.broadcast(userid, :say_hello)
      |> case do
        {:ok, 0} ->
          nil

        {:ok, n_recipients} ->
          IO.puts("told #{n_recipients} processes to say hello to #{userid}")
      end
    end

    Process.send_after(self(), :say_hello_to_all_clients, 20_000)
    {:noreply, state}
  end
end