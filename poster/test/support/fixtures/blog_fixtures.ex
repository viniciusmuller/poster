defmodule Poster.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poster.Blog` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> Poster.Blog.create_post()

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
      |> Poster.Blog.create_comment(post)

    comment
  end
end
