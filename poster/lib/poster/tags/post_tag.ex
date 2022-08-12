defmodule Poster.Tags.PostTag do
  use Ecto.Schema

  @primary_key false
  schema "posts_tags" do
    belongs_to :post, Poster.Posts.Post
    belongs_to :tag, Poster.Tags.Tag
  end
end

