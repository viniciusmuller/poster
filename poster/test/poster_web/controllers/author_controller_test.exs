defmodule PosterWeb.AuthorControllerTest do
  use PosterWeb.ConnCase

  import Poster.PostsFixtures
  import Poster.BlogFixtures

  alias Poster.Posts.Post

  describe "show" do
    setup [:create_post_with_author]

    test "lists all posts from a given author", %{conn: conn, author: author} do
      conn = get(conn, Routes.author_path(conn, :show, author))
      assert html_response(conn, 200) =~ "1 post"

      add_post_to_author(author)

      conn = get(conn, Routes.author_path(conn, :show, author))
      assert html_response(conn, 200) =~ "2 posts"
    end

    test "does not list posts that are not from the author", %{conn: conn, author: author} do
      for _ <- 1..10, do: post_fixture()

      conn = get(conn, Routes.author_path(conn, :show, author))
      assert html_response(conn, 200) =~ "1 post"
    end

    test "paginates author posts", %{conn: conn, author: author} do
      author_id = author.id
      for _ <- 1..100, do: %Post{author_id: ^author_id} = add_post_to_author(author)

      assert conn
             |> get(Routes.author_path(conn, :show, author, page: 1))
             |> html_response(200) =~ "Page 1 of"

      assert conn
             |> get(Routes.author_path(conn, :show, author, page: 2))
             |> html_response(200) =~ "Page 2 of"
    end

    test "does not show 'author' in posts", %{conn: conn, author: author} do
      author_id = author.id
      for _ <- 1..10, do: %Post{author_id: ^author_id} = add_post_to_author(author)

      refute conn
             |> get(Routes.author_path(conn, :show, author, page: 1))
             |> html_response(200) =~ "Author: #{author.name}"
    end
  end

  defp create_post_with_author(_) do
    user = user_author_fixture()
    post = post_author_fixture(user.author)
    %{post: post, author: user.author}
  end

  defp add_post_to_author(author) do
    post_author_fixture(%{}, author)
  end
end
