defmodule MyApp.Httpd.Params do
  def get(req, name, default_val \\ nil, :list) when is_atom(name) do
    :cowboy_req.match_qs([{name, _constraints = [], ""}], req)
    |> get_in([name])
    |> case do
      "" -> default_val || []
      item when is_binary(item) -> [item]
      items when is_list(items) -> items
    end
  end
end