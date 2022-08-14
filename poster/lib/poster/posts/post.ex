defmodule Poster.Posts.Post do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Poster.Markdown
  alias Poster.Tags.Tag
  alias Poster.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :body, :string
    field :title, :string
    field :slug, :string
    field :thumbnail_url, :string
    field :tags_raw, :string, virtual: true

    many_to_many :tags, Poster.Tags.Tag,
      join_through: Poster.PostTag,
      on_delete: :delete_all,
      on_replace: :delete

    has_many :comments, Poster.Posts.Comment
    belongs_to :author, Poster.Blog.Author

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :tags_raw])
    |> validate_required([:title, :body, :tags_raw])
    |> validate_length(:body, min: 10, max: 2000)
    |> validate_length(:title, min: 1, max: 80)
    |> create_slug()
    |> find_cover()
    |> product_tags()
  end

  @doc false
  def update_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :tags_raw])
    |> validate_required([:title, :body, :tags_raw])
    |> validate_length(:body, min: 10, max: 2000)
    |> validate_length(:title, min: 1, max: 80)
    |> find_cover()
    |> product_tags()
  end


  @doc """
  Search posts and their tags for a given term.

  Note: Returns duplicated results, distinct needs to be called when sorting.
  More information: https://github.com/elixir-ecto/ecto/issues/1937
  """
  def search(query, nil), do: query

  def search(query, search_term) do
    wildcard_search = "%#{search_term}%"

    from post in query,
      join: t in assoc(post, :tags),
      # distinct: post.id,
      where:
        ilike(post.title, ^wildcard_search) or
          ilike(post.body, ^wildcard_search) or
          ilike(t.title, ^wildcard_search),
      preload: [tags: t]
  end

  def add_raw_tags(changeset, post) do
    change(changeset, tags_raw: tags_to_string(post.tags))
  end

  defp tags_to_string(tags) do
    Enum.map_join(tags, ", ", & &1.title)
  end

  defp product_tags(%Ecto.Changeset{valid?: true, changes: %{tags_raw: tags}} = changeset) do
    tags = tags |> parse_tags() |> Enum.uniq_by(& &1.title)

    if is_list(tags) and length(tags) >= 2 do
      tag_names = for t <- tags, do: t.title
      tags = Enum.map(tag_names, &get_or_insert_tag/1)
      Ecto.Changeset.put_assoc(changeset, :tags, tags)
    else
      add_error(changeset, :tags_raw, "must have at least 2 tags")
    end
  end

  defp product_tags(changeset), do: changeset

  defp parse_tags(tags) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    for tag <- String.split(tags, ","),
        tag = tag |> String.trim() |> String.downcase(),
        tag != "",
        do: %{title: tag, inserted_at: now, updated_at: now}
  end

  defp get_or_insert_tag(title) do
    Repo.get_by(Tag, title: title) || Repo.insert!(%Tag{title: title})
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
