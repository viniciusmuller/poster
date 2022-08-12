defmodule PosterWeb.PostController do
  use PosterWeb, :controller

  alias Poster.Posts
  alias Poster.Posts.Post

  def index(conn, _params) do
    posts = Posts.list_posts([:comments, :author])
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    created_post =
      case Map.get(conn.assigns, :current_user) do
        # anonymous user
        nil ->
          Posts.create_post(post_params)

        user ->
          Posts.create_post(user.author, post_params)
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

    {:ok, html_doc, []} = Earmark.as_html(post.body)

    conn
    |> assign(:rendered_markdown, html_doc)
    |> render("show.html", post: post)
  end

  def edit(conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(slug)
    changeset = Posts.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"slug" => slug, "post" => post_params}) do
    post = Posts.get_post_by_slug!(slug)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(slug)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end
end
