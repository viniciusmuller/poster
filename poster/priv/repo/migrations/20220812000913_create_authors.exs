defmodule Poster.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :user_id, :binary_id

      timestamps()
    end
  end
end
