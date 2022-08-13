defmodule PosterWeb.AuthorView do
  use PosterWeb, :view

  alias Poster.Posts.Post

  def get_posts_string(posts) do
    case length(posts) do
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

  def render_tags(tags) do
    for(tag <- tags, do: tag.title) |> Enum.join(", ")
  end
end
