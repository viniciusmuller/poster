defmodule Poster.Repo.Migrations.AssociatePostsAndTags do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :tag_id, :binary_id
      add :tags_raw, :text
    end

    alter table(:tags) do
      add :post_id, :binary_id
    end
  end
end
