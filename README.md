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
