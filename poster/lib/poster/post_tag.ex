defmodule Poster.PostTag do
  @moduledoc """
  Describes the association between posts and tags
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts_tags" do
    field :post_id, :binary_id
    field :tag_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(post_tag, attrs) do
    post_tag
    |> cast(attrs, [])
    |> validate_required([])
  end
end
