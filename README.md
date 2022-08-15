# Poster
![ci status](https://github.com/arcticlimer/poster/actions/workflows/ci.yml/badge.svg)

![poster home page](./.github/img/poster_home.png)

Poster is a realtime web application made with the [PETAL
stack](https://thinkingelixir.com/petal-stack-in-elixir/) that allows users to
share knowledge and chat through posts and comments, which can be published in
an authenticated or anonymous way.

# Table of Contents
- [Features](#features)
  * [Markdown rendering](#markdown-rendering)
  * [Post covers](#post-covers)
  * [Clean URL slugs](#clean-url-slugs)
  * [Realtime capabilities](#realtime-capabilities)
  * [Observability](#observability)
- [Made with](#made-with)
  * [Elixir + Phoenix](#elixir---phoenix)
  * [Tests](#tests)
  * [GitHub](#github)
  * [Tailwind CSS](#tailwind-css)
  * [Alpine JS](#alpine-js)
  * [Docker](#docker)
- [Development Setup](#development-setup)
  * [Installing development environment](#installing-development-environment)
    + [With asdf](#with--asdf--https---asdf-vmcom-)
    + [With Nix](#with--nix--https---nixosorg-downloadhtml-)
  * [Start dependencies with docker-compose](#start-dependencies-with-docker-compose)
  * [Enter the application directory](#enter-the-application-directory)
  * [Setup the project](#setup-the-project)
  * [Run the project](#run-the-project)
- [Running with Docker](#running-with-docker)
- [Running with docker-compose](#running-with-docker-compose)

# Features
## Markdown rendering
Users can share their ideas in posts using [Markdown](https://commonmark.org/).
This provides great flexibility for users creating their posts and a powerful
opporunity for the application's code to parse this markdown and make sense of it
to give it meaningful representations.

## Post covers
By parsing the contents of a post, Poster can detect images and by default sets
the first image of a post to be its cover when listing it.

## Clean URL slugs
Posts are given an unique slug based on their titles when created. This slug
will uniquely identify a post in the system and cannot be changed.
> Example: A post titled "25 Reasons to Learn Elixir" might have an URL similar
> to `https://poster.example/p/25-reasons-to-learn-elixir-aryi4`

## Realtime capabilities
Poster provides great realtime features for users, such as having new posts and
comments being automatically shown to all users that are eligible to see them.

> Example: If someone is browsing posts at Poster, and you publish a new
> post, this person will see your post pop up in her screen.

## Observability

By using [PromEx](https://github.com/akoutmos/prom_ex), the systems enable
prometheus support in the `/metrics` endpoint and integrates with Grafana to
provide observability to the system administrators:

![grafana beam vm dashboard](./.github/img/grafana_beam_dashboard.png)
![grafana phoenix endpoint dashboard](./.github/img/grafana_phoenix_dashboard.png)

# Made with
## Elixir + Phoenix
The [Phoenix Framework](https://www.phoenixframework.org/) allows one to easily
mix server-side rendered layouts and realtime interactive pages with an enormous
ease. The realtime features of this project are provided by [Phoenix
PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html) and [Phoenix
LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).

## Tests
Since Phoenix makes it extremely easy to test complex interaction with pages,
the app contains a big test suite that ensures the main features of the
application are tested and the code coverage remains at around 90%.

## GitHub
The project uses GitHub Actions as its continuous integration mechanism to
ensure that code is properly formatted, tests are passing and type-checking
points no errors.

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
