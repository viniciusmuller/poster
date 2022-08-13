defmodule PosterWeb.AuthorView do
  use PosterWeb, :view

  alias Poster.Posts.Post

  def get_posts_string(total_posts) do
    case total_posts do
      0 -> "This user has no posts yet"
      1 -> "1 post"
      n -> "#{n} posts"
    end
  end

  def author_name(%Post{} = post) do
    case post.author_id do
      nil -> "Anonymous"
      _ -> post.author.name
    end
  end

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
    for(tag <- tags, do: tag.title) |> Enum.join(", ")
  end
end
