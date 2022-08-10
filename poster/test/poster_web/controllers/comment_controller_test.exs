defmodule PosterWeb.CommentControllerTest do
  use PosterWeb.ConnCase

  import Poster.BlogFixtures

  alias Poster.Blog.Comment

  @create_attrs %{
    body: "some body"
  }
  @update_attrs %{
    body: "some updated body"
  }
  @invalid_attrs %{body: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all comments", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create comment" do
    setup [:create_post]

    test "renders comment when data is valid", %{conn: conn, post: post} do
      post_id = post.id
      attrs = Map.put(@create_attrs, "post_id", post_id)
      conn = post(conn, Routes.comment_path(conn, :create), comment: attrs)
      assert %{"id" => id, "post_id" => ^post_id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.comment_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "post_id" => ^post_id,
               "body" => "some body"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.comment_path(conn, :create), comment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update comment" do
    setup [:create_comment]

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
  end

  describe "delete comment" do
    setup [:create_comment]

    test "deletes chosen comment", %{conn: conn, comment: comment} do
      conn = delete(conn, Routes.comment_path(conn, :delete, comment))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.comment_path(conn, :show, comment))
      end
    end
  end

  defp create_comment(_) do
    comment = comment_fixture()
    %{comment: comment}
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end
end
