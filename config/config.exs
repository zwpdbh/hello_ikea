# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :nx, default_backend: EXLA.Backend

config :ash_oban, pro?: false

config :hello, Oban,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  queues: [default: 10],
  repo: Hello.Repo,
  plugins: [{Oban.Plugins.Cron, []}]

config :ash,
  allow_forbidden_field_for_relationships_by_default?: true,
  include_embedded_source_by_default?: false,
  show_keysets_for_all_actions?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false],
  keep_read_action_loads_when_loading?: false,
  default_actions_require_atomic?: true,
  read_action_after_action_hooks_in_order?: true,
  bulk_actions_default_to_errors?: true

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :admin,
        :authentication,
        :tokens,
        :postgres,
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [
      section_order: [:admin, :resources, :policies, :authorization, :domain, :execution]
    ]
  ]

config :hello,
  ecto_repos: [Hello.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [Hello.Accounts, Hello.Rag, Hello.Chat]

config :hello, Hello.Repo, types: Hello.PostgrexTypes

# Configures the endpoint
config :hello, HelloWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: HelloWeb.ErrorHTML, json: HelloWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Hello.PubSub,
  live_view: [signing_salt: "GBlrroN8"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :hello, Hello.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  hello: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  hello: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :venomous, :snake_manager, %{
  # TTL whenever python process is inactive. Default: 15
  snake_ttl_minutes: 10,
  # Number of python workers that don't get cleared by SnakeManager when their TTL while inactive ends. Default: 10
  perpetual_workers: 1,
  # Interval for killing python processes past their ttl while inactive. Default: 60_000ms (1 min)
  cleaner_interval: 5_000,
  # reload module for hot reloading.
  # default is already provided inside venomous python/ directory
  reload_module: :reload,

  # Erlport python options
  python_opts: [
    module_paths: ["priv/python"],
    python_executable: "/usr/bin/python3",
    envvars: [
      TRANSFORMERS_CACHE: "/your/hf/cache"
    ]
  ]
}

config :venomous, :serpent_watcher, [
  # Defaults to false
  enable: true,
  # log every hot reload. Default: true
  logging: true,
  # Provided by default
  module: :serpent_watcher,
  # Provided by default
  func: :watch_directories,
  # Provided by default
  manager_pid: Venomous.SnakeManager
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
