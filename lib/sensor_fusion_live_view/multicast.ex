defmodule SensorFusionLiveView.Multicast do

  use GenServer

  @multicast_address {224,0,2,254}
  @multicast_port 62476

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, addrs} = :inet.getifaddrs
    own_addr = hd(
      for {_, opts} <- addrs, {:addr, addr} <- opts, tuple_size(addr) == 4, addr != {127,0,0,1}, do: addr
    )
    {:ok, sock} = :gen_udp.open(@multicast_port, [
      :binary,
      :inet,
      active: true,
      multicast_if: own_addr,
      multicast_loop: false,
      reuseaddr: true,
      add_membership: {@multicast_address, own_addr}
    ])
  end

  def handle_info({:udp, socket, ip, port, data}, state) do
    IO.inspect [:erlang.binary_to_term(data)]
    case :erlang.binary_to_term(data) do
      {:measure, name, {node, iter, measure}} ->
        Phoenix.PubSub.broadcast(SensorFusionLiveView.PubSub, "sonars:measurements", {name, {node, iter, measure}})
      _ -> nil
    end
    {:noreply, state}
  end
end
