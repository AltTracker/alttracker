# Alt Tracker

Alt Tracker is a beautiful, simple, cryptocurrency portfolio management tool written with [Phoenix](https://phoenixframework.org)

## Keys

- `:open_exchange_key` - for querying currency data through [open exchange rates](https://openexchangerates.org/account/app-ids)

## Getting started

Once downloaded, follow these steps in order to get the app up and running on your local machine.

- Install dependencies:

```
$ mix do deps.get, deps.compile
$ cd assets && npm install && node node_modules/brunch/bin/brunch build
```

- Change `Postgres` username in _/config/dev.exs_ to your own username.

- Create the database:

```
 $ mix ecto.create
```

- Migrate database:

```
$ mix ecto.migrate
```

- Start your server:

```
$ mix phx.server
```

You should now have the application running on port `4000`: _localhost:4000_
