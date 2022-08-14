defmodule Poster.Repo do
  use Ecto.Repo,
    otp_app: :poster,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
