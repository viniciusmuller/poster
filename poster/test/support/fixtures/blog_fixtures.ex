defmodule Poster.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poster.Blog` context.
  """

  import Poster.AccountsFixtures

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Poster.Blog.create_author()

    author
  end

  @doc """
  Generate an author associated with an user account.
  """
  def user_author_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)
    user |> Poster.Repo.preload(:author)
  end
end
