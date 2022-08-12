defmodule Poster.Repo.Migrations.AddPostThumbnailUrl do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :thumbnail_url, :string
    end
  end
end
