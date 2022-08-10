defmodule Poster.Repo.Migrations.AddPostSlug do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :slug, :string
    end
  end
end
