defmodule Poster.Posts.Post do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Poster.Markdown

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :body, :string
    field :title, :string
    field :slug, :string
    field :thumbnail_url, :string
    has_many :comments, Poster.Posts.Comment
    belongs_to :author, Poster.Blog.Author

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:body, min: 10, max: 2000)
    |> validate_length(:title, min: 1, max: 80)
    |> create_slug()
    |> find_cover()
  end

  @doc false
  def update_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:body, min: 10, max: 2000)
    |> validate_length(:title, min: 1, max: 80)
    |> find_cover()
  end

  defp create_slug(%Ecto.Changeset{valid?: true, changes: %{title: title}} = changeset) do
    discriminator = random_string(5)
    slug = Slug.slugify(title, truncate: 50)
    change(changeset, slug: "#{slug}-#{discriminator}")
  end

  defp create_slug(changeset), do: changeset

  defp find_cover(%Ecto.Changeset{valid?: true, changes: %{body: body}} = changeset) do
    url =
      case Markdown.extract_cover(body) do
        {:ok, url} -> url
        {:error, :cover_not_found} -> nil
      end

    change(changeset, thumbnail_url: url)
  end

  defp find_cover(changeset), do: changeset

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
