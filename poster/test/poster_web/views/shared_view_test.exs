defmodule PosterWeb.SharedViewTest do
  use PosterWeb.ConnCase, async: true

  alias PosterWeb.SharedView

  describe "pagination_button_classes/2" do
    test "returns active if current page is the same as the target page" do
      assert SharedView.pagination_button_classes(10, 10) =~ "bg-blue-600"
      refute SharedView.pagination_button_classes(10, 12) =~ "bg-blue-600"
    end
  end
end
