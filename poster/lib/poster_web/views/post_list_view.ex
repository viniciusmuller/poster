defmodule PosterWeb.PostListView do
  use PosterWeb, :view

  def relative_post_date(time) do
    Timex.format!(time, "{relative}", :relative)
  end

  def render_comments_number(comments) do
    case length(comments) do
      0 -> "No comments yet"
      1 -> "1 comment"
      n -> "#{n} comments"
    end
  end
end
