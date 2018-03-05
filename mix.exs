defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.6-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MyApp.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.2"},
      #{:syn, "~> 1.6"},
      {:phoenix_pubsub, "~> 1.0"},
      {:uuid, "~> 1.1"},
      # Elixir-compatible :ets.fun2ms/1
      {:ex2ms, "~> 1.0"},
    ]
  end
end
