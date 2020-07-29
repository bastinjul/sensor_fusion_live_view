defmodule SensorFusionLiveViewWeb.SonarsCalculations do
  use SensorFusionLiveViewWeb, :live_view

  def render(assigns) do
    ~L"""
    <%= for k <- Keyword.keys(@calculation) do %>
      <%= if k == :position do %>
        <h2>Positions of the object</h2>
        <%= for node <- Map.keys(@calculation[k]) do %>
          <p>
            <% {iter, pos} = @calculation[k][node] %>
            Position of the object, performed by node <%= node %> at iteration <%= iter %> :
            <%= for {x, y} <- pos do %>
              (x: <%= x %>, y: <%= y %>)
            <% end %>
          </p>
        <% end %>
      <% end %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SensorFusionLiveView.PubSub, "position:calculations")

    {:ok, put_calculation(socket)}
  end

  def handle_info(calculation = _, socket) do
    {:noreply, put_calculation(socket, calculation)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  defp put_calculation(socket, calculation \\ [position: %{node@nohost: {-1, [{0,0}]}}]) do
    assign(socket, :calculation, calculation)
  end

end
