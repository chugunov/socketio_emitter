# socketio_emitter

[![Build Status](https://api.travis-ci.org/chugunov/socketio_emitter.svg?branch=master)](https://travis-ci.org/chugunov/socketio_emitter)
[![Hex.pm](https://img.shields.io/hexpm/v/socketio_emitter.svg)](https://hex.pm/packages/socketio_emitter)

`socketio_emitter` allows you to communicate with socket.io servers easily from Elixir processes.

## Installation

The package can be installed
by adding `socketio_emitter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:socketio_emitter, "~> 0.1.1"}]
end
```

## How to use

Register `socketio_emitter` supervisor at your supervisor tree:

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

Then call `SocketIOEmitter.emit/2`:

```elixir
msg = %{:text => "hello"}

# sending to all clients
{:ok, _consumers_count} =  SocketIOEmitter.emit ["broadcast", msg]

# sending to all clients in 'game' room
{:ok, _consumers_count} =  SocketIOEmitter.emit ["new-game", msg],
  rooms: ["game"]
  
# sending to individual socketid (private message)
{:ok, _consumers_count} =  SocketIOEmitter.emit ["private", msg],
  rooms: [socket_id]
  
# sending to all clients in 'admin' namespace
{:ok, _consumers_count} =  SocketIOEmitter.emit ["namespace", msg],
  nsp: "/admin"
  
# sending to all clients in 'admin' namespace and in 'notifications' room
{:ok, _consumers_count} =  SocketIOEmitter.emit ["namespace", msg],
  nsp: "/admin",
  rooms: ["notifications"]
```

## Configuration

You can configure `socketio_emitter` from your `config.exs`. 
See the [redix documentation](https://hexdocs.pm/redix/Redix.html#start_link/2) for the possible values of `redix_config`.

```elixir
use Mix.Config

config :socketio_emitter, :redix_pool,
  redix_config: [
    # default value: localhost
    host: "example.com",
    # default value: 6379
    port: 5000,
  ],
  # 5 Redix processes will be available (default value: 1)
  pool_size: 5
```
Or passing by parameters directly to supervisor, in this way values from config will be **overridden**:

```elixir
redix_pool = [redix_config: [
    host: "localhost",
    port: 6379
  ], pool_size: 3]

children = [
  # Add this line to your supervisor tree
  supervisor(SocketIOEmitter, [redix_pool], [name: :socket_emitter])
]
```

## TODO

- tests
- documentation

## License

MIT
