defmodule Poster.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :body, :string
    belongs_to :post, Poster.Blog.Post

    timestamps()
  end

  @doc false
  def changeset(comment, post, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> put_assoc(:post, post)
  end

  @doc false
  def update_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
