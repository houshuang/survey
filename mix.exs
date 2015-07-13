defmodule Survey.Mixfile do
  use Mix.Project

  def project do
    [app: :survey,
      version: "0.0.1",
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Survey, []},
      applications: [:phoenix, :phoenix_html, :cowboy, :logger,
        :phoenix_ecto, :postgrex, :dogstatsd, :httpoison, :plug_accesslog ]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["plugs", "lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["plugs", "lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.13"},
      {:phoenix_ecto, "~> 0.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 1.0"},
      {:phoenix_live_reload, "~> 0.4", only: :dev},
      {:cowboy, "~> 1.0"},
      {:poison, "~> 1.4.0"},
      {:mix_test_watch, "~> 0.1.0"},
      {:multidef, github: "pragdave/mdef"},
      {:plug_lti, github: "houshuang/plug_lti"},
      {:httpoison, "~> 0.7"},
      {:dogstatsd, "0.0.3"},
      {:exprintf, github: "parroty/exprintf"},
      {:param_session, github: "houshuang/param_session"},
      {:csv, "~> 1.0.0"},
      {:plug_accesslog, github: "houshuang/plug_accesslog"},
      {:mailman, github: "houshuang/mailman"},
      {:eiconv, github: "zotonic/eiconv"},
      {:hashids, "~> 2.0"}
    ]
  end
end
