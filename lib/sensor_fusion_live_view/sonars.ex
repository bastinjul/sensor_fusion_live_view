defmodule SensorFusionLiveView.Sonars do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(opts) do
    Phoenix.PubSub.subscribe(SensorFusionLiveView.PubSub, "sonars:measurements")

    {:ok, opts}
  end

  def handle_call(:measurements, _from, measurements) do
    IO.puts("handle_call sonar")
    {:reply, measurements, measurements}
  end

  def handle_info(measurements = _, _old) do
    IO.puts("handle_info sonar")
    {:noreply, measurements}
  end

  def get do
    GenServer.call(__MODULE__, :measurements)
  end
end