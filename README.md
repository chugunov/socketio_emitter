# socketio_emitter

`socketio_emitter` allows you to communicate with socket.io servers easily from Elixir processes.

## Installation

The package can be installed
by adding `socketio_emitter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:socketio_emitter, "~> 0.1.0"}]
end
```

## How to use

```elixir
defmodule ExampleApp do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # Add this line to your supervisor tree
      supervisor(SocketIOEmitter, []),
    ]

    opts = [strategy: :one_for_one, name: ExampleApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Configuration

You can configure `socketio_emitter` from your `config.exs`, ex.:

```elixir
use Mix.Config

config :socketio_emitter, :redix_config,
  # default value: localhost
  host: "example.com", 
  # default value: 6379
  port: 5000,
  # 5 Redix processes will be available (default value: 1)
  pool_size: 5
```

Or passing by parameters directly to supervisor:

```elixir
children = [
  # Add this line to your supervisor tree
  supervisor(SocketIOEmitter, [host: "example.com", port: 9999, password: "secret"], [name: :socket_emitter])
]
```

## TODO

- tests
- documentation

## License

MIT
