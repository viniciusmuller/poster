defmodule PosterWeb.CommentView do
  use PosterWeb, :view
  alias PosterWeb.CommentView

  def render("index.json", %{comments: comments}) do
    %{data: render_many(comments, CommentView, "comment.json")}
  end

  def render("show.json", %{comment: comment}) do
    %{data: render_one(comment, CommentView, "comment.json")}
  end

  def render("comment.json", %{comment: comment}) do
    %{
      id: comment.id,
      body: comment.body,
      post_id: comment.post_id,
      author:
        if is_nil(comment.author_id) do
          nil
        else
          %{
            name: comment.author.name
          }
        end
    }
  end
end
