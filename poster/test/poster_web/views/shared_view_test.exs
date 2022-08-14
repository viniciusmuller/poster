defmodule PosterWeb.SharedViewTest do
  use PosterWeb.ConnCase, async: true

  import Poster.PostsFixtures
  import Poster.BlogFixtures

  alias PosterWeb.SharedView

  describe "pagination_button_classes/2" do
    test "returns active if current page is the same as the target page" do
      assert SharedView.pagination_button_classes(10, 10) =~ "bg-blue-600"
      refute SharedView.pagination_button_classes(10, 12) =~ "bg-blue-600"
    end
  end

  describe "render_tags/1" do
    test "receives a list of tag objects and joins it with comma" do
      target = "a, b, c, d"
      tags = for c <- ["a, b, c, d"], do: %{title: c}
      assert target == SharedView.render_tags(tags)
    end
  end

  describe "author_name/1 - posts" do
    test "returns the name of the author if it exists" do
      name = "mr tester"
      author = author_fixture(%{name: name})
      post = post_author_fixture(%{}, author)
      assert SharedView.author_name(post) == name
    end

    test "returns 'Anonymous' if there's no author" do
      post = post_fixture()
      assert SharedView.author_name(post) == "Anonymous"
    end
  end

  describe "author_name/1 - comments" do
    test "returns the name of the author if it exists" do
      name = "mr tester"
      author = author_fixture(%{name: name})
      comment = comment_author_fixture(%{}, author)
      assert SharedView.author_name(comment) == name
    end

    test "returns 'Anonymous' if there's no author" do
      comment = comment_fixture()
      assert SharedView.author_name(comment) == "Anonymous"
    end
  end
end
