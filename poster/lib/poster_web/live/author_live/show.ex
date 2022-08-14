defmodule PosterWeb.AuthorLive.Show do
  use PosterWeb, :live_view

  alias Poster.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    author = Blog.get_author!(id)

    page =
      Blog.get_author_posts(author)
      |> Poster.Repo.paginate(params)

    {:noreply,
     socket
     |> assign(:page_title, author_title(author.name))
     |> assign(:author, author)
     |> assign(:page, page)}
  end

  defp author_title(name) do
    "#{name}'s profile'"
  end

  defp get_posts_string(total_posts) do
    case total_posts do
      0 -> "This user has no posts yet"
      1 -> "1 post"
      n -> "#{n} posts"
    end
  end

  defp pagination_button_classes(current_page, target) do
    non_selected =
      "flex items-center justify-center w-10 h-10 text-blue-600 transition-colors duration-150 bg-white rounded-full focus:shadow-outline hover:bg-blue-100"

    selected =
      "flex items-center justify-center w-10 h-10 text-white bg-blue-600 rounded-full focus:shadow-outline"

    if target == current_page do
      selected
    else
      non_selected
    end
  end
end
