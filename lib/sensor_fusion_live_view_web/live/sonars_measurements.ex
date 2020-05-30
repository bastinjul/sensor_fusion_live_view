defmodule SensorFusionLiveViewWeb.SonarsMeasurements do
  use SensorFusionLiveViewWeb, :live_view

  def render(assigns) do
    {name, {node, iter, {data, timestamp}}} = assigns.measurement
    ~L"""
    Current measurements of sonar <%= node %> : iter = <%= iter%>, measurement = <%=data%>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SensorFusionLiveView.PubSub, "sonars:measurements")

    {:ok, put_measurement(socket)}
  end

  def handle_info(measurement = _, socket) do
    {:noreply, put_measurement(socket, measurement)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  defp put_measurement(socket, measurement \\ {:sonar, {:node@nohost, -1, {0, 0}}}) do
    assign(socket, :measurement, measurement)
  end

end
