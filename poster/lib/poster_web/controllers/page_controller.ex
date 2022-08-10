defmodule PosterWeb.PageController do
  use PosterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
