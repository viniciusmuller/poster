defmodule PosterWeb.PostView do
  use PosterWeb, :view

  alias Poster.Posts.Post

  def author_name(%Post{} = post) do
    case post.author_id do
      nil -> "Anonymous"
      _ -> post.author.name
    end
  end

  def render_tags(tags) do
    Enum.map_join(tags, ", ", & &1.title)
  end
end
