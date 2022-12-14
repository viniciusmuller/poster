defmodule Poster.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Poster.Repo

  alias Poster.Posts.Post
  alias Poster.Posts.Comment
  alias Poster.Blog.Author

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts("query")
      [%Post{}, ...]

  """
  def list_posts(search_term \\ nil) do
    Post |> Post.search(search_term)
  end

  @doc """
  Sorts a list of posts by different criteria

  # https://github.com/elixir-ecto/ecto/issues/1937
  """
  def sort_posts(query, {:recently_updated, :asc}) do
    query
    |> distinct([p], asc: p.updated_at)
    |> order_by([p], asc: p.updated_at)
  end

  def sort_posts(query, {:recently_updated, :desc}) do
    query
    |> distinct([p], desc: p.updated_at)
    |> order_by([p], desc: p.updated_at)
  end

  def sort_posts(query, {:new, :asc}) do
    query
    |> distinct([p], asc: p.inserted_at)
    |> order_by([p], asc: p.inserted_at)
  end

  def sort_posts(query, {:new, :desc}) do
    query
    |> distinct([p], desc: p.inserted_at)
    |> order_by([p], desc: p.inserted_at)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id, preloads \\ []) do
    Repo.get!(Post, id) |> Repo.preload(preloads)
  end

  @doc """
  Retrieves comments from a specific posts
  """
  def post_comments(%Post{id: id}) do
    from c in Comment,
      where: c.post_id == ^id,
      order_by: [desc: c.inserted_at]
  end

  @doc """
  Gets a single post by its slug.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post_by_slug!(123)
      %Post{}

      iex> get_post_slug!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post_by_slug!(slug, preloads \\ []) do
    query =
      from p in Post,
        where: p.slug == ^slug,
        preload: [comments: :author]

    Repo.one!(query) |> Repo.preload(preloads)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, preloads \\ []) do
    result =
      %Post{}
      |> Post.changeset(attrs)
      |> Repo.insert()

    with {:ok, post} <- result do
      {:ok, Repo.preload(post, preloads)}
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post_with_author(%{field: value}, %Author{})
      {:ok, %Post{}}

      iex> create_post_with_author(%{field: bad_value}, %Author{})
      {:error, %Ecto.Changeset{}}

  """
  def create_post_with_author(attrs \\ %{}, %Author{} = author) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:author, author)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  alias Poster.Posts.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments(preloads \\ []) do
    Repo.all(Comment) |> Repo.preload(preloads)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id, preloads \\ []) do
    Repo.get!(Comment, id) |> Repo.preload(preloads)
  end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value}, %Post{})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value}, %Post{})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}, %Post{} = post) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Repo.insert()
  end

  @doc """
  Creates a comment associating it with an author.

  ## Examples

      iex> create_comment(%{field: value}, %Post{}, %Author{})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value}, %Post{}, %Author{})
      {:error, %Ecto.Changeset{}}

  """
  # credo:disable-for-next-line
  def create_comment_with_author(attrs \\ %{}, %Post{} = post, author = %Author{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Ecto.Changeset.put_assoc(:author, author)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.update_changeset(comment, attrs)
  end
end
