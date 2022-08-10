defmodule PosterWeb.PostControllerTest do
  use PosterWeb.ConnCase

  import Poster.BlogFixtures

  @create_attrs %{body: "some body some body some body ", title: "some title"}
  @update_attrs %{body: "some updated body once told me the world", title: "some updated title"}
  @invalid_attrs %{body: nil, title: nil}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert html_response(conn, 200) =~ "Recent Posts"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :new))
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.post_path(conn, :show, slug)

      conn = get(conn, Routes.post_path(conn, :show, slug))
      assert html_response(conn, 200) =~ @create_attrs.title
    end

    test "escapes unsafe xss payloads", %{conn: conn} do
      malicious_payload = "<script>alert('danger')</script>"
      conn = post(conn, Routes.post_path(conn, :create), post: %{@create_attrs | body: malicious_payload})

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.post_path(conn, :show, slug)

      conn = get(conn, Routes.post_path(conn, :show, slug))
      refute html_response(conn, 200) =~ malicious_payload
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :edit, post.slug))
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post.slug), post: @update_attrs)
      assert redirected_to(conn) == Routes.post_path(conn, :show, post.slug)

      conn = get(conn, Routes.post_path(conn, :show, post.slug))
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post.slug), post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.slug))
      assert redirected_to(conn) == Routes.post_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.post_path(conn, :show, post.slug))
      end
    end
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end
end
