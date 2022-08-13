defmodule PosterWeb.PostController do
  use PosterWeb, :controller

  import PosterWeb.UserAuth
  plug :require_authenticated_user when action in [:edit, :update, :delete]

  action_fallback(PosterWeb.FallbackController)

  alias Poster.Posts
  alias Poster.Markdown
  alias Poster.Blog
  alias Poster.Posts.Post

  def index(conn, _params) do
    posts = Posts.list_posts([:comments, :author, :tags])
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{tags: []})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    created_post =
      case Map.get(conn.assigns, :current_user) do
        # anonymous user
        nil ->
          Posts.create_post(post_params)

        user ->
          Posts.create_post_with_author(post_params, user.author)
      end

    case created_post do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(slug, [:comments, :author])

    html_doc = Markdown.to_html!(post.body)

    conn
    |> assign(:rendered_markdown, html_doc)
    |> render("show.html", post: post)
  end

  def edit(conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(slug, [:tags])
    changeset = Posts.change_post(post)

    with :ok <- ensure_ownership(conn.assigns.current_user.author, post) do
      render(conn, "edit.html", post: post, changeset: Post.add_raw_tags(changeset, post))
    end
  end

  def update(conn, %{"slug" => slug, "post" => post_params}) do
    post = Posts.get_post_by_slug!(slug, [:tags])

    with :ok <- ensure_ownership(get_author(conn), post) do
      case Posts.update_post(post, post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: Routes.post_path(conn, :show, post.slug))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(slug)

    with :ok <- ensure_ownership(get_author(conn), post) do
      {:ok, _post} = Posts.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.post_path(conn, :index))
    end
  end

  defp ensure_ownership(author, post) do
    case Blog.is_owner?(author, post) do
      true -> :ok
      false -> {:error, :forbidden}
    end
  end

  defp get_author(conn) do
    conn.assigns.current_user.author
  end
end
