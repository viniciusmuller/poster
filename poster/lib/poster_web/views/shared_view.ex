defmodule PosterWeb.SharedView do
  use PosterWeb, :view

  alias Poster.Posts.Post
  alias Poster.Posts.Comment

  def pagination_button_classes(current_page, target) do
    non_selected =
      "flex items-center justify-center w-10 h-10 text-blue-600 transition-colors duration-150 bg-white rounded-full focus:shadow-outline hover:bg-blue-100"

    selected =
      "flex items-center justify-center w-10 h-10 text-white bg-blue-600 rounded-full focus:shadow-outline"

    if target == current_page do
      selected
    else
      non_selected
    end
  end

  def render_tags(tags) do
    Enum.map_join(tags, ", ", & &1.title)
  end

  def author_name(%Post{} = post) do
    case post.author_id do
      nil -> "Anonymous"
      _ -> post.author.name
    end
  end

  def author_name(%Comment{} = comment) do
    case comment.author_id do
      nil -> "Anonymous"
      _ -> comment.author.name
    end
  end
end
