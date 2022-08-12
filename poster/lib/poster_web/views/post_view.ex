defmodule PosterWeb.PostView do
  use PosterWeb, :view

  alias Poster.Posts.Post

  def safe_html(html_body) do
    {:safe, sanitized} = sanitize(html_body)
    sanitized
  end

  def author_name(%Post{} = post) do
    case post.author_id do
      nil -> "Anonymous"
      _ -> post.author.name
    end
  end
end
