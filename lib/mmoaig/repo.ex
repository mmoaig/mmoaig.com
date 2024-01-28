defmodule Mmoaig.Repo do
  use Ecto.Repo,
    otp_app: :mmoaig,
    adapter: Ecto.Adapters.Postgres
end
