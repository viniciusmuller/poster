defmodule Poster.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poster.Blog` context.
  """

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
end
