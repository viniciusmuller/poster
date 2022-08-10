defmodule PosterWeb.PostView do
  use PosterWeb, :view

  def safe_html(html_body) do
    {:safe, sanitized} = sanitize(html_body)
    sanitized
  end
end
