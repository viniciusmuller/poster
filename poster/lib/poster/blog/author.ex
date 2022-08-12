defmodule Poster.Blog.Author do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "authors" do
    field :name, :string
    belongs_to :user, Poster.Accounts.User
    has_many :posts, Poster.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 80)
  end
end
