defmodule PosterWeb.PostViewTest do
  use PosterWeb.ConnCase, async: true

  import Poster.BlogFixtures
  import Poster.PostsFixtures
  alias PosterWeb.PostView

  describe "author_name/1" do
    test "returns the name of the author if it exists" do
      name = "mr tester"
      author = author_fixture(%{name: name})
      post = post_author_fixture(%{}, author)
      assert PostView.author_name(post) == name
    end

    test "returns 'Anonymous' if there's no author" do
      post = post_fixture()
      assert PostView.author_name(post) == "Anonymous"
    end
  end

  describe "render_tags/1" do
    test "receives a list of tag objects and joins it with comma" do
      target = "a, b, c, d"
      tags = for c <- ["a, b, c, d"], do: %{title: c}
      assert target == PostView.render_tags(tags)
    end
  end
end
