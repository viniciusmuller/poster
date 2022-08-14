defmodule PosterWeb.PostLiveTest do
  use PosterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Poster.PostsFixtures

  alias Poster.Posts

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end

  defp create_posts(_) do
    posts = for n <- 1..10, do: post_fixture(%{title: post_name(n)})
    %{posts: posts}
  end

  defp post_name(n) do
    case rem(n, 2) do
      1 -> "foo"
      _ -> "bar"
    end
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Recent Posts"
    end
  end

  describe "Query posts" do
    setup [:create_posts]

    test "can search for posts", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))

      html =
        view
        |> element("#search-form")
        |> render_change(query: %{"query" => "foo"})

      assert html =~ "foo"
      refute html =~ "bar"

      html =
        view
        |> element("#search-form")
        |> render_change(query: %{"query" => "nonsense"})

      refute html =~ "foo"
      refute html =~ "bar"
    end
  end

  describe "Show" do
    setup [:create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, Routes.post_show_path(conn, :show, post.slug))

      assert html =~ post.title
    end

    test "display comments of a post", %{conn: conn, post: post} do
      msg = "live view is awesome"
      Posts.create_comment(%{body: msg}, post)
      {:ok, _show_live, html} = live(conn, Routes.post_show_path(conn, :show, post.slug))
      assert html =~ msg
    end
  end

  describe "create comment - authenticated" do
    setup [:create_post, :register_and_log_in_user]

    test "creates comment when data is valid and associates user with comment", %{
      conn: conn,
      post: post,
      user: user
    } do
      {:ok, view, _html} = live(conn, Routes.post_show_path(conn, :show, post.slug))
      body = "new comment"

      result =
        view
        |> element("#comment-form")
        |> render_submit(comment: %{body: body})

      assert result =~ body
      assert result =~ user.author.name
    end

    test "renders errors when comment data is invalid", %{conn: conn, post: post} do
      {:ok, view, _html} = live(conn, Routes.post_show_path(conn, :show, post.slug))
      body = ""

      result =
        view
        |> element("form#comment-form")
        |> render_submit(comment: %{body: body})

      assert result =~ "invalid-feedback"
    end
  end

  describe "create comment - unauthenticated" do
    setup [:create_post]

    test "renders comment when data is valid and comment has no author", %{
      conn: conn,
      post: post
    } do
      {:ok, view, _html} = live(conn, Routes.post_show_path(conn, :show, post.slug))
      body = "message"

      result =
        view
        |> element("#comment-form")
        |> render_submit(comment: %{body: body})

      assert result =~ "Author: Anonymous"
      assert result =~ "message"
    end
  end
end
