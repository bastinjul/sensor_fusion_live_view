defmodule SensorFusionLiveViewWeb.RoomTracker do
  use SensorFusionLiveViewWeb, :live_view

  @width 10
  @room_height 600
  @room_width 600
  @precision_cm 1

  def render(assigns) do
    ~L"""
    <div class="room-container"
        style="width: <%= @room_width + @width %>px;
                height: <%= @room_height + @width %>px">
      <%= for o <- @object_pos do %>
        <div class="block object"
            style="left: <%= x(o[:x], @coef_x) %>px;
                    top: <%= x(o[:y], @coef_y) %>px;
                    width: <%= @width %>px;
                    height: <%= @width %>px;"></div>
      <% end %>
      <%= for s <- @sonars do %>
        <div class="block sonar"
            style="left: <%= x(s[:x], @coef_x) %>px;
                    top: <%= x(s[:y], @coef_y) %>px;
                    width: <%= @width %>px;
                    height: <%= @width %>px;"></div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SensorFusionLiveView.PubSub, "position:calculations")
    Phoenix.PubSub.subscribe(SensorFusionLiveView.PubSub, "room:pos")

    {:ok, socket |> build_room() |> place_sonars() |> place_object()}
  end

  def handle_info(pos = [pos: map], socket) do
    {:noreply, place_sonars(socket, pos)}
  end

  def handle_info(calculation = [position: map], socket) do
    {:noreply, place_object(socket, calculation)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  defp build_room(socket) do
    defaults = %{
      room_width: @room_width,
      room_height: @room_height,
      coef_x: 1,
      coef_y: 1,
      width: @width
    }
    assign(socket, defaults)
  end

  defp x(x_idx, coef), do: x_idx*coef
  defp y(y_odx, coef), do: y_odx*coef

  defp sonar(x_idx, y_idx, width) do
    %{type: :sonar, x: x_idx * width, y: y_idx * width, width: width}
  end

  defp object(x_idx, y_idx, width) do
    %{type: :object, x: x_idx * width, y: y_idx * width, width: width}
  end

  defp place_sonars(socket, sonars \\ [pos: %{node@nohost: {-1, {%{x: -1, y: -1, node_id: -1}, -1}}}]) do
    positions = for node <- Map.keys(sonars[:pos]) do
      {_, {%{x: x, y: y, node_id: _}, _}} = sonars[:pos][node]
      %{x: x, y: y}
    end
    socket
    |> coef_x(positions)
    |> coef_y(positions)
    |> assign(:sonars, positions)
  end

  defp coef_x(socket, positions) do
    max_x = List.foldl(positions, 1, fn pos, acc -> if pos[:x] > acc, do: pos[:x], else: acc end)
    max_x = if max_x == 1, do: 600, else: max_x
    assign(socket, :coef_x, div(@room_width, max_x))
  end

  defp coef_y(socket, positions) do
    max_y = List.foldl(positions, 1, fn pos, acc -> if pos[:y] > acc, do: pos[:y], else: acc end)
    max_y = if max_y == 1, do: 600, else: max_y
    assign(socket, :coef_y, div(@room_width, max_y))
  end

  defp place_object(socket, object_positions \\ [position: %{node@nohost: {-1, 'x1, 10.5, y1, 10.5, x2, 10.5, y2, -10.5'}}]) do
    positions = object_positions[:position]
    object_pos = for k <- Map.keys(positions) do
      {_, pos} = positions[k]
      s = String.split(String.replace(to_string(pos), ",", ""))
      {x, _} = List.pop_at(s, 1)
      {y, _} = List.pop_at(s, 3)
      %{x: String.to_float(x), y: String.to_float(y), width: @width}
    end
    assign(socket, :object_pos, object_pos)
  end
end
