defmodule Poster.Repo.Migrations.AddCommentAuthorId do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :author_id, :binary_id
    end
  end
end
