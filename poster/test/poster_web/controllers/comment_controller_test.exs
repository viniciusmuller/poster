defmodule PosterWeb.CommentControllerTest do
  use PosterWeb.ConnCase

  import Poster.PostsFixtures
  import Poster.BlogFixtures

  alias Poster.Posts.Comment
  alias Poster.Accounts

  @create_attrs %{
    body: "some body"
  }
  @update_attrs %{
    body: "some updated body"
  }
  @invalid_attrs %{body: nil}

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, PosterWeb.Endpoint.config(:secret_key_base))
      |> put_req_header("accept", "application/json")
      |> init_test_session(%{})
      |> fetch_flash()

    %{conn: conn}
  end

  describe "index" do
    test "lists all comments", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create comment - authorized" do
    setup [:add_post, :add_author, :authenticate]

    test "renders comment when data is valid and associates user with comment", %{
      conn: conn,
      post: post,
      user: user
    } do
      post_id = post.id
      author_name = user.author.name
      attrs = Map.put(@create_attrs, "post_id", post_id)
      conn = post(conn, Routes.comment_path(conn, :create), comment: attrs)
      assert %{"id" => id, "post_id" => ^post_id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.comment_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "post_id" => ^post_id,
               "body" => "some body",
               "author" => %{
                 "name" => ^author_name
               }
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.comment_path(conn, :create), comment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create comment - unauthenticated" do
    setup [:add_post]

    test "renders comment when data is valid and comment has no author", %{
      conn: conn,
      post: post
    } do
      post_id = post.id
      attrs = Map.put(@create_attrs, "post_id", post_id)
      conn = post(conn, Routes.comment_path(conn, :create), comment: attrs)
      assert %{"id" => id, "post_id" => ^post_id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.comment_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "post_id" => ^post_id,
               "body" => "some body",
               "author" => nil
             } = json_response(conn, 200)["data"]
    end
  end

  describe "update comment - authenticated" do
    setup [:create_comment_with_author, :authenticate]

    test "renders comment when data is valid", %{conn: conn, comment: %Comment{id: id} = comment} do
      conn = put(conn, Routes.comment_path(conn, :update, comment), comment: @update_attrs)
      assert %{"id" => ^id, "post_id" => post_id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.comment_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some updated body",
               "post_id" => ^post_id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment} do
      conn = put(conn, Routes.comment_path(conn, :update, comment), comment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "cannot update post_id", %{
      conn: conn,
      comment: %Comment{id: id, post_id: original_post_id} = comment
    } do
      attrs = Map.put(@update_attrs, "post_id", "7d879742-6f1f-4e72-90bd-5f03e5488c14")
      conn = put(conn, Routes.comment_path(conn, :update, comment), comment: attrs)
      assert %{"id" => ^id, "post_id" => ^original_post_id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.comment_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some updated body",
               "post_id" => ^original_post_id
             } = json_response(conn, 200)["data"]
    end
  end

  describe "update comment - unauthenticated" do
    setup [:create_comment_with_author]

    test "fails to delete comment when unauthenticated", %{
      conn: conn,
      comment: comment
    } do
      conn = put(conn, Routes.comment_path(conn, :update, comment))
      assert conn.status == 401
    end
  end

  describe "update comment - unauthorized" do
    setup [:create_comment_with_author, :add_author, :authenticate]

    test "fails to edit comment when unauthorized", %{conn: conn, comment: comment} do
      data = %{
        id: comment.id,
        comment: comment
      }

      conn = put(conn, Routes.comment_path(conn, :update, comment), data)
      assert conn.status == 403
    end
  end

  describe "delete comment - unauthenticated" do
    setup [:create_comment_with_author]

    test "fails to edit comment when unauthenticated", %{conn: conn, comment: comment} do
      conn = delete(conn, Routes.comment_path(conn, :update, comment))
      assert conn.status == 401
    end
  end

  describe "delete comment - unauthorized" do
    setup [:create_comment_with_author, :add_author, :authenticate]

    test "fails to delete comment when unauthorized", %{conn: conn, comment: comment} do
      conn = delete(conn, Routes.comment_path(conn, :delete, comment))
      assert conn.status == 403

      conn = get(conn, Routes.comment_path(conn, :show, comment))
      assert conn.status == 200
    end
  end

  describe "delete comment - authorized" do
    setup [:create_comment_with_author, :authenticate]

    test "deletes chosen comment when authenticated", %{conn: conn, comment: comment} do
      conn = delete(conn, Routes.comment_path(conn, :delete, comment))
      assert conn.status == 204

      assert_error_sent 404, fn ->
        get(conn, Routes.comment_path(conn, :show, comment))
      end
    end
  end

  defp create_comment_with_author(_) do
    user = user_author_fixture()
    comment = comment_author_fixture(user.author)
    %{comment: comment, user: user}
  end

  defp add_post(data) do
    Map.put(data, :post, post_fixture())
  end

  defp add_author(data) do
    Map.put(data, :user, user_author_fixture())
  end

  defp authenticate(%{user: user, conn: conn} = data) do
    token = Accounts.generate_user_session_token(user)
    Map.put(data, :conn, put_session(conn, :user_token, token))
  end
end
