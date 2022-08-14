defmodule PosterWeb.AuthorLiveTest do
  use PosterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Poster.BlogFixtures

  defp create_author(_) do
    author = author_fixture()
    %{author: author}
  end

  describe "Show" do
    setup [:create_author]

    test "displays author", %{conn: conn, author: author} do
      {:ok, _show_live, html} = live(conn, Routes.author_show_path(conn, :show, author))

      assert html =~ author.name
    end
  end
end
