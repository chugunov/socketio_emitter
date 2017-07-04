defmodule SocketIOEmitter do
  @moduledoc """
  Module allows you to communicate with socket.io servers easily from Elixir processes.
  """

  use Supervisor
  
  @root_nsp "/"
  @prefix "socket.io"
  @uid "emitter"
  @parser_event_type 2
  @default_redix_config [pool_size: 1]
  @redix_conf Application.get_env(:socketio_emitter, :redix_config, @default_redix_config)

  def start_link(redis_opts \\ [])
  def start_link(redis_opts) do
    Supervisor.start_link(__MODULE__, redis_opts, name: __MODULE__)
  end
  
  def init(redis_opts) do
    redix_workers = 
      for i <- 0..(@redix_conf[:pool_size] - 1) do
        worker(Redix, [redis_opts, [name: :"redix_#{i}"]], id: {Redix, i})
      end

    opts = [strategy: :one_for_one, name: SocketIOEmitter.Supervisor]
    supervise(redix_workers, opts)
  end

  @doc """
  Pack message
  """
  def pack_msg!(args, opts \\ []) do
    nsp = Keyword.get(opts, :nsp, @root_nsp)
    rooms = Keyword.get(opts, :rooms, [])
    flags = Keyword.get(opts, :flags, [])
    prefix = Keyword.get(opts, :prefix, @prefix)

    packet = %{:type => @parser_event_type, :data => args, :nsp => nsp}
    flags_ = Enum.reduce(flags, %{}, &Map.put(&2, &1, true))
    opts = %{:rooms => rooms, :flags => flags_}

    channel = 
      case length(rooms) do
        1 -> "#{prefix}##{nsp}##{hd(rooms)}#"
        _ -> "#{prefix}##{nsp}#"
      end

    binary_msg =
      [@uid, packet, opts]
      |> Msgpax.pack!
      |> IO.iodata_to_binary

    {channel, binary_msg}
  end

  @doc """
  Emit message to socket.io
  """
  def emit(args, opts \\ []) when is_list(args) do
    {:ok, emit!(args, opts)}
  rescue
    _error -> 
      {:error, :wrong_data}
  end

  def emit!(args, opts \\ []) when is_list(args) do
    {channel, binary_msg} = pack_msg!(args, opts)
    Redix.command!(:"redix_#{random_index()}", ["PUBLISH", channel, binary_msg])
  end

  defp random_index() do
    "#{rem(System.unique_integer([:positive]), @redix_conf[:pool_size])}"
  end
end
