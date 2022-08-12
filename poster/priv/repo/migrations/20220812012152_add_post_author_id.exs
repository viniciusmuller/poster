defmodule Poster.Repo.Migrations.AddPostAuthorId do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :author_id, :binary_id
    end
  end
end
