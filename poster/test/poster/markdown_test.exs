defmodule Poster.MarkdownTest do
  use ExUnit.Case

  alias Poster.Markdown

  describe "to_html!/1" do
    test "to_html! converts markdown into html" do
      assert Markdown.to_html!("# hello!") == "<h1>\nhello!</h1>\n"
    end
  end

  describe "extract_cover/1" do
    test "extracts the first image of a markdown document" do
      cover_target = "http://example.com/my-image.png"

      data = """
      # test payload

      ## Nested heading
      ![this is the cover](#{cover_target})

      # Bye
      ![this should not be the cover](http://example.com/fake-cover.png)
      """

      assert Markdown.extract_cover(data) == {:ok, cover_target}
    end

    test "returns error tuple if image cannot be found" do
      data = """
      # test payload

      ## Nested heading
      [no image here](http://foo.com)
      """

      assert Markdown.extract_cover(data) == {:error, :cover_not_found}
    end
  end
end
