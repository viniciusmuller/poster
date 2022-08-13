defmodule Poster.Repo.Migrations.CreatePostsTags do
  use Ecto.Migration

  def change do
    create table(:posts_tags, primary_key: false) do
      add :id, :binary_id, primary_key: false
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id), primary_key: true
      add :tag_id, references(:tags, on_delete: :nothing, type: :binary_id), primary_key: true

      timestamps()
    end

    create index(:posts_tags, [:post_id])
    create index(:posts_tags, [:tag_id])
  end
end
