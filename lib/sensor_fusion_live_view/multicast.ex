defmodule SensorFusionLiveView.Multicast do

  use GenServer

  @multicast_address {224,0,2,254}
  @multicast_port 62476

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(:calculations, [:private, :named_table, :ordered_set])
    :ets.new(:measurements, [:private, :named_table, :ordered_set])
    {:ok, addrs} = :inet.getifaddrs
    own_addr = hd(
      for {_, opts} <- addrs, {:addr, addr} <- opts, tuple_size(addr) == 4, addr != {127,0,0,1}, do: addr
    )
    {:ok, _sock} = :gen_udp.open(@multicast_port, [
      :binary,
      :inet,
      active: true,
      multicast_if: own_addr,
      multicast_loop: false,
      reuseaddr: true,
      add_membership: {@multicast_address, own_addr}
    ])
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    msg = :erlang.binary_to_term(data)
    case msg do
      {:measure, :sonar, {node, iter, measure}} ->
        update_table(:measurements, :sonar, node, iter, measure)
        Phoenix.PubSub.broadcast(SensorFusionLiveView.PubSub, "sonars:measurements", :ets.tab2list(:measurements))
      {:measure, :pos, {node, iter, measure}} ->
        update_table(:measurements, :pos, node, iter, measure)
        Phoenix.PubSub.broadcast(SensorFusionLiveView.PubSub, "pos:measurements", :ets.tab2list(:measurements))
      {:calc, name, {node, iter, calculation}} ->
        update_table(:calculations, name, node, iter, calculation)
        Phoenix.PubSub.broadcast(SensorFusionLiveView.PubSub, "position:calculations", :ets.tab2list(:calculations))
      _ -> :nil
    end
    {:noreply, state}
  end

  def update_table(table, name, node, iter, data) do
    unless :ets.member(table, name) do
      :ets.insert(table, {name, %{}})
    end
    map = :ets.lookup(table, name)[name]
    map = Map.put(map, node, {iter, data})
    :ets.insert(table, {name, map})
  end
end
