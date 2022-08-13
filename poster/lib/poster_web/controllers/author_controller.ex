defmodule PosterWeb.AuthorController do
  use PosterWeb, :controller

  alias Poster.Blog

  def show(conn, %{"id" => id} = params) do
    author = Blog.get_author!(id)

    page =
      Blog.get_author_posts(author)
      |> Poster.Repo.paginate(params)

    conn
    |> render("show.html", author: author, page: page)
  end
end
