# Poster
![ci status](https://github.com/arcticlimer/poster/actions/workflows/ci.yml/badge.svg)

Poster is a realtime web application made with the [PETAL
stack](https://thinkingelixir.com/petal-stack-in-elixir/) that allows users to
share knowledge and chat through posts and comments, which can be published in
an authenticated or anonymous way.

# Features
## Markdown rendering

## Posts cover URL

## Clean URL slugs

## Realtime capabilities

## Realtime capabilities

## Observability

## Made with
## Elixir + Phoenix
The [Phoenix Framework](https://www.phoenixframework.org/) allows one to easily
mix server-side rendered layouts and realtime interactive pages with an enormous
ease. The realtime features of this project are provided by [Phoenix
PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html) and [Phoenix
LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).

## Tailwind CSS
[Tailwind CSS](https://tailwindcss.com/) considerably boosts developer
productivity when designing beautiful, modern, responsive applications.

## Alpine JS
[Alpine JS](https://tailwindcss.com/) comes to the rescue by simplifying
non-serverside client interactions, such as toggling the open state of the app's navbar.

## Docker
[Docker](https://www.docker.com/) allows this project to be easily deployed in
production environments and helps building a reliable and reproducible
development environment.

# Development Setup

## Installing development environment
### With [asdf](https://asdf-vm.com)
```sh
asdf install
```

### With [Nix](https://nixos.org/download.html)
```sh
nix develop
```

## Start dependencies with docker-compose
```sh
docker-compose -f docker-compose.dev.yml up -d
```

## Enter the application directory
```sh
cd poster
```

## Setup the project
If you have not already run it, run:
```sh
mix setup
```

## Run the project
```sh
iex -S mix phx.server
```

# Running with Docker
```
docker run \
  --env DATABASE_URL=ecto://user:pass@host/database \
  --env PGDATABASE=poster \
  --env PGPORT=5432 \
  --env PGHOST=pg_host \
  --env PGUSER=postgres \
  --env PGPASSWORD=pg_pass \
  --env DATABASE_URL=ecto://user:pass@host/database \
  --env SECRET_KEY_BASE=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  poster
```

# Running with docker-compose
```
docker-compose up
```
