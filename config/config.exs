# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cryptofolio,
  ecto_repos: [Cryptofolio.Repo]

# Configures the endpoint
config :cryptofolio, Cryptofolio.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sxQSOeOiH0ikyWwn0BsurcBBGE4Cpl7mv62H6J0ZBjrWNHOhaviItKzZb1UMooAF",
  render_errors: [view: Cryptofolio.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cryptofolio.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Cryptofolio.User,
  repo: Cryptofolio.Repo,
  module: Cryptofolio,
  router: Cryptofolio.Web.Router,
  messages_backend: Cryptofolio.Coherence.Messages,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :registerable]

config :coherence, Cryptofolio.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%

config :canary,
  repo: Cryptofolio.Repo
