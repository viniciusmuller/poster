defmodule Poster.TagsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poster.Tags` context.
  """

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Poster.Tags.create_tag()

    tag
  end
end
