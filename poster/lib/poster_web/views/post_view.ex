defmodule PosterWeb.PostView do
  use PosterWeb, :view

  alias Poster.Posts.{Comment, Post}

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

  def author_name(%Comment{} = comment) do
    case comment.author_id do
      nil -> "Anonymous"
      _ -> comment.author.name
    end
  end

  def is_owner(author, post) do
    post.author_id == author.id
  end

  def render_tags(tags) do
    for(tag <- tags, do: tag.title) |> Enum.join(", ")
  end
end
