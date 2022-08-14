defmodule Poster.Tags.Tag do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tags" do
    field :title, :string

    many_to_many :posts, Poster.Posts.Post,
      join_through: Poster.PostTag,
      on_delete: :delete_all,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:title])
    |> validate_length(:title, min: 1, max: 20)
    |> validate_required([:title])
  end
end
