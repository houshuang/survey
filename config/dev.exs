use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :survey, Survey.Endpoint,
  http: [port: 8000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch"]]

  # Watch static and templates for browser reloading.
  config :survey, Survey.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ],
  reloadable_paths: ["web", "lib"],
  code_reload: [
    reloadable_paths: ["web", "lib"]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, 
  level: :info,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:id]

# Configure your database
config :survey, Survey.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "stian",
  password: "",
  database: "survey_dev",
  extensions: [{Extensions.JSON, library: Poison}],
  size: 10 # The amount of database connections in the pool

config :plug_lti,
  base_url: "http://localhost:8000",
  lti_key: "test",
  lti_secret: "secret",
  plug_disabled: true

config :verify_admin,
  password: "test"

config :grade,
  dont_submit: true

import_config "dev.secret.exs"
