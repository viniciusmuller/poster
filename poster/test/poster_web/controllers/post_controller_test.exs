defmodule PosterWeb.PostControllerTest do
  use PosterWeb.ConnCase

  import Poster.PostsFixtures
  import Poster.BlogFixtures

  alias Poster.Accounts
  alias Poster.Posts
  alias Poster.Posts.Post

  @create_attrs %{
    body: "some body some body some body ",
    title: "some title",
    tags_raw: "music, games"
  }
  @update_attrs %{
    body: "some updated body once told me the world",
    title: "some updated title",
    tags_raw: "music, books"
  }
  @invalid_attrs %{body: nil, title: nil}

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, PosterWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{conn: conn}
  end

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert html_response(conn, 200) =~ "Recent Posts"
    end

    test "paginates posts", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert html_response(conn, 200) =~ "Total results"
      assert html_response(conn, 200) =~ "Page 1 of"
    end
  end

  describe "show" do
    setup [:create_post_with_author]

    test "renders specific posts", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :show, post.slug))
      assert html_response(conn, 200) =~ post.title
    end

    test "paginates post comments", %{conn: conn, post: post} do
      for _ <- 1..100, do: {:ok, _comment} = add_comment_to_post(post)

      assert conn
             |> get(Routes.post_path(conn, :show, post.slug, page: 1))
             |> html_response(200) =~ "Next Page"

      assert conn
             |> get(Routes.post_path(conn, :show, post.slug, page: 2))
             |> html_response(200) =~ "Prev Page"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :new))
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post - unauthenticated" do
    test "can create posts in an anonymous way", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.post_path(conn, :show, slug)

      conn = get(conn, Routes.post_path(conn, :show, slug))
      assert html_response(conn, 200) =~ @create_attrs.title
    end

    test "escapes unsafe xss payloads", %{conn: conn} do
      malicious_payload = "<script>alert('danger')</script>"

      conn =
        post(conn, Routes.post_path(conn, :create),
          post: %{@create_attrs | body: malicious_payload}
        )

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

  describe "create post - authenticated" do
    setup [:add_author, :authenticate]

    test "can create posts when authenticated", %{conn: conn, user: user} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.post_path(conn, :show, slug)

      conn = get(conn, Routes.post_path(conn, :show, slug))
      assert html_response(conn, 200) =~ @create_attrs.title
      assert html_response(conn, 200) =~ user.author.name
    end
  end

  describe "edit post - authorized" do
    setup [:create_post_with_author, :authenticate]

    test "renders form for editing chosen post user is post owner", %{
      conn: conn,
      post: post
    } do
      response = get(conn, Routes.post_path(conn, :edit, post.slug))
      assert html_response(response, 200) =~ "Edit Post"
    end
  end

  describe "edit post - unauthenticated" do
    setup [:create_post_with_author]

    test "redirects user to login if user is not authenticated", %{
      conn: conn,
      post: post
    } do
      response = get(conn, Routes.post_path(conn, :edit, post.slug))
      assert redirected_to(response) == Routes.user_session_path(conn, :new)
    end
  end

  describe "edit post - unauthorized" do
    setup [:create_post_with_author, :add_author, :authenticate]

    test "redirects user to / if it is authenticated but is not post owner", %{
      conn: conn,
      post: post
    } do
      response = get(conn, Routes.post_path(conn, :edit, post.slug))
      assert redirected_to(response) == Routes.post_path(conn, :index)
    end
  end

  describe "update post - authenticated " do
    setup [:create_post_with_author, :authenticate]

    test "redirects to post when data is valid", %{conn: conn, post: post} do
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

  describe "update post - unauthenticated " do
    setup [:create_post_with_author]

    test "redirect to login when unauthenticated", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post.slug), post: @update_attrs)
      response = get(conn, Routes.post_path(conn, :edit, post.slug))
      assert redirected_to(response) == Routes.user_session_path(conn, :new)
    end
  end

  describe "update post - unauthorized " do
    setup [:create_post_with_author, :add_author, :authenticate]

    test "redirect to / when unauthorized", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post.slug), post: @update_attrs)
      assert redirected_to(conn) == Routes.post_path(conn, :index)
    end
  end

  describe "delete post - unauthenticated" do
    setup [:create_post_with_author]

    test "redirects to login if unauthenticated", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.slug))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      conn = get(conn, Routes.post_path(conn, :show, post.slug))
      assert html_response(conn, 200) =~ post.title
    end
  end

  describe "delete post - authenticated" do
    setup [:create_post_with_author, :authenticate]

    test "deletes chosen post when authenticated", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.slug))
      assert redirected_to(conn) == Routes.post_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.post_path(conn, :show, post.slug))
      end
    end
  end

  describe "delete post - unauthorized" do
    setup [:create_post_with_author, :add_author, :authenticate]

    test "redirects to index if unauthorized", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.slug))
      assert redirected_to(conn) == Routes.post_path(conn, :index)

      conn = get(conn, Routes.post_path(conn, :show, post.slug))
      assert html_response(conn, 200) =~ post.title
    end
  end

  defp create_post_with_author(_) do
    user = user_author_fixture()
    post = post_author_fixture(user.author)
    %{post: post, user: user}
  end

  defp add_author(data) do
    Map.put(data, :user, user_author_fixture())
  end

  defp add_comment_to_post(%Post{} = post) do
    Posts.create_comment(%{body: "aaaaaaaaaaaaaaaaa"}, post)
  end

  defp authenticate(%{user: user, conn: conn} = data) do
    token = Accounts.generate_user_session_token(user)
    Map.put(data, :conn, put_session(conn, :user_token, token))
  end
end
