defmodule SocketIOEmitterTest do
  use ExUnit.Case
  doctest SocketIOEmitter

  setup_all do
    assert {:ok, _pid} = SocketIOEmitter.start_link
    :ok
  end

  test "should successfully start supervisor and emit simple message" do
    msg = %{:text => "hello"}
    assert {:ok, _consumers_count} =  SocketIOEmitter.emit ["private", msg], 
        nsp: "/admin", 
        rooms: ["username"], 
        flags: [:broadcast]
  end

  test "should pack message with default parameters" do
    msg = %{:text => "hello"}
    {channel, binary_msg} = 
      SocketIOEmitter.pack_msg! ["private", msg]

    expected_pack = 
     ["emitter", 
      %{data: ["private",msg], nsp: "/", type: 2}, 
      %{flags: %{}, rooms: []}]
    
    assert channel == "socket.io#/#"
    assert binary_msg == 
      expected_pack
      |> Msgpax.pack! 
      |> IO.iodata_to_binary
  end

  test "should pack message to namspace and room with broadcast flag" do
    msg = %{:text => "hello"}
    {channel, binary_msg} = 
      SocketIOEmitter.pack_msg! ["private", msg], 
        nsp: "/admin", 
        rooms: ["username"], 
        flags: [:broadcast]

    expected_pack = 
     ["emitter", 
      %{data: ["private",msg], nsp: "/admin", type: 2}, 
      %{flags: %{broadcast: true}, rooms: ["username"]}]
    
    assert channel == "socket.io#/admin#username#"
    assert binary_msg == 
      expected_pack
      |> Msgpax.pack! 
      |> IO.iodata_to_binary
  end
end
