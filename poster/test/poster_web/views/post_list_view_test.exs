defmodule PosterWeb.PostListViewTest do
  use PosterWeb.ConnCase, async: true

  alias PosterWeb.PostListView

  describe "render_comments_number/1" do
    test "correctly pluralizes number of comments" do
      assert PostListView.render_comments_number([1]) == "1 comment"
      assert PostListView.render_comments_number([1, 2]) == "2 comments"
      assert PostListView.render_comments_number([]) == "No comments yet"
    end
  end
end
