defmodule SocketioEmitter.Mixfile do
  use Mix.Project

  def project do
    [app: :socketio_emitter,
     version: "0.1.0",
     elixir: "~> 1.2",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     source_url: "https://github.com/chugunov/socketio_emitter"]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :redix]]
  end

  defp description do
    """
    `socketio_emitter` allows you to communicate with socket.io servers easily from Elixir processes.
    """
  end

  defp package do
    [
      name: :socketio_emitter,
      files: ["lib",  "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Andrey Chugunov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/chugunov/socketio_emitter"}
    ]
  end

  defp deps do
    [ 
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:redix, "~> 0.6.1"},
      {:msgpax, "~> 2.0"}
    ]
  end
end
