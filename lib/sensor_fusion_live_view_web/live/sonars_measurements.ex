defmodule SensorFusionLiveViewWeb.SonarsMeasurements do
  use SensorFusionLiveViewWeb, :live_view

  def render(assigns) do

    ~L"""
    <%= for k <- Keyword.keys(@measurement) do %>
      <%= if k == :pos do %>
        <h2>Positions of the sonars</h2>
        <%= for node <- Map.keys(@measurement[k]) do %>
          <p>
            <% {iter, {pos, _}} = @measurement[k][node] %>
            Position of sonar <%= node %> : (x: <%= pos[:x] %>, y: <%= pos[:y] %>)
          </p>
        <% end %>
      <%= else %>
        <h2>Sonar measurements</h2>
        <%= for node <- Map.keys(@measurement[k]) do %>
          <p>
            <% {iter, {range, _}} = @measurement[k][node] %>
            Range of sonar <%= node %> = <%= range %>, iteration = <%= iter %>
          </p>
        <% end %>
      <% end %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SensorFusionLiveView.PubSub, "sonars:measurements")
    Phoenix.PubSub.subscribe(SensorFusionLiveView.PubSub, "pos:measurements")

    {:ok, put_measurement(socket)}
  end

  def handle_info(measurement = _, socket) do
    {:noreply, put_measurement(socket, measurement)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  defp put_measurement(socket, measurement \\ [pos: %{node@nohost: {-1, {%{x: -1, y: -1, node_id: -1}, -1}}}, sonar: %{node@nohost: {-1, {0, 0}}}]) do
    assign(socket, :measurement, measurement)
  end

end
