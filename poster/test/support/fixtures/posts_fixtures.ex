defmodule Poster.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poster.Posts` context.
  """

  alias Poster.Blog.Author

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body once told me the world",
        title: "some title",
        tags_raw: "music, games"
      })
      |> Poster.Posts.create_post([:tags])

    post
  end

  @doc """
  Generate a post and associates it with given author.
  """
  def post_author_fixture(attrs \\ %{}, %Author{} = author) do
    attrs =
      Enum.into(attrs, %{
        body: "some body once told me the world",
        title: "some title",
        tags_raw: "music, games"
      })

    {:ok, post} = Poster.Posts.create_post_with_author(attrs, author)
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

  @doc """
  Generate a comment and associates it with an author.
  """
  def comment_author_fixture(attrs \\ %{}, %Author{} = author) do
    post = post_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Poster.Posts.create_comment_with_author(post, author)

    comment
  end
end
