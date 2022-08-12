defmodule Poster.Posts.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :body, :string
    belongs_to :post, Poster.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(comment, post, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 1, max: 240)
    |> put_assoc(:post, post)
  end

  @doc false
  def update_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_length(:body, min: 1, max: 240)
    |> validate_required([:body])
  end
end
