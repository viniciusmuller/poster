defmodule PosterWeb.PostListView do
  use PosterWeb, :view

  alias Poster.Posts.Post

  def author_name(%Post{} = post) do
    case post.author_id do
      nil -> "Anonymous"
      _ -> post.author.name
    end
  end

  def relative_post_date(time) do
    Timex.format!(time, "{relative}", :relative)
  end

  def render_tags(tags) do
    for(tag <- tags, do: tag.title) |> Enum.join(", ")
  end

  def render_comments_number(comments) do
    case length(comments) do
      0 -> "No comments yet"
      1 -> "1 comment"
      n -> "#{n} comments"
    end
  end
end
