defmodule PosterWeb.PostLiveTest do
  use PosterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Poster.PostsFixtures

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Recent Posts"
    end
  end

  describe "Show" do
    setup [:create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, Routes.post_show_path(conn, :show, post.slug))

      assert html =~ post.title
    end
  end
end
