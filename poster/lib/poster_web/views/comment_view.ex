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
    base = %{
      id: comment.id,
      body: comment.body,
      post_id: comment.post_id,
    }
    case comment.author do
      %Ecto.Association.NotLoaded{} -> base
      author -> Map.put(base, :author, %{
          name: author.name
      })
    end
  end
end
