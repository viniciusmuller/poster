## Development Setup

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
