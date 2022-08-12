defmodule Poster.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poster.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body once told me the world",
        title: "some title"
      })
      |> Poster.Posts.create_post()

    post
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    post = post_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Poster.Posts.create_comment(post)

    comment
  end
end
