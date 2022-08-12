defmodule Poster.Markdown do
  @moduledoc """
  Provides helper functions related to markdown
  """

  @doc """
  Converts markdown to HTML

  IMPORTANT: This method does not sanitize input and it requires further
  sanitization in order to be rendered in a browser
  """
  def to_html!(markdown_payload) do
    Earmark.as_html!(markdown_payload)
  end

  @doc """
  Tries to extract a cover image from a markdown document

  Returns `nil` if not cover could be found
  """
  def extract_cover(markdown_payload) do
    with {:ok, ast, _} <- Earmark.as_ast(markdown_payload) do
      case do_ast_search(ast) do
        nil -> {:error, :cover_not_found}
        img -> {:ok, img}
      end
    end
  end

  defp do_ast_search(ast) do
    Enum.reduce_while(ast, nil, fn node, acc ->
      with {"p", _, [{"img", attributes, _, _}], _} <- node,
           {:ok, src} <- do_search_for_src(attributes) do
        {:halt, src}
      else
        _ -> {:cont, acc}
      end
    end)
  end

  defp do_search_for_src(attributes) do
    result =
      Enum.find(attributes, fn
        {"src", _} -> true
        _ -> false
      end)

    case result do
      {"src", src} ->
        {:ok, src}

      nil ->
        {:error, :src_not_found}
    end
  end
end
