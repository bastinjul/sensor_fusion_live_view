defmodule SensorFusionLiveView.Repo do
  use Ecto.Repo,
    otp_app: :sensor_fusion_live_view,
    adapter: Ecto.Adapters.Postgres
end
