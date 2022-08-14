## Development Setup

### Installing development environment
#### With [asdf](https://asdf-vm.com)
```sh
asdf install
```

#### With [Nix](https://nixos.org/download.html)
```sh
nix develop
```

### Start dependencies with docker-compose
```sh
docker-compose -f docker-compose.dev.yml up -d
```

### Enter the application directory
```sh
cd poster
```

### Setup the project
If you have not already run it, run:
```sh
mix setup
```

### Run the project
```sh
iex -S mix phx.server
```

## Running with Docker
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
