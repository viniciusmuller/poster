defmodule PosterWeb.PostLive.Index do
  use PosterWeb, :live_view

  @topic "posts"

  alias Poster.Posts

  @impl true
  def mount(params, _session, socket) do
    PosterWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :posts, list_posts(params))}
  end

  @impl true
  def handle_info(%{topic: @topic, payload: post}, socket) do
    post = Poster.Repo.preload(post, [:author, :comments, :tags])

    posts =
      if socket.assigns.page.page_number < 2 do
        [post | socket.assigns.posts]
      else
        socket.assigns.posts
      end

    {:noreply, assign(socket, :posts, posts)}
  end

  @impl true
  def handle_event("search", %{"search" => query}, socket) do
    {:noreply, push_patch(socket, to: Routes.post_index_path(socket, :index, query))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    {posts, page} = list_posts(params)

    socket
    |> assign(:page_title, "Browsing Posts")
    |> assign(:posts, posts)
    |> assign(:page, page)
  end

  defp list_posts(params) do
    IO.inspect(params)
    search_term =
      with query <- get_in(params, ["query"]),
           true <- query != "" do
        query
      else
        _ -> nil
      end

    page =
      search_term
      |> Posts.list_posts()
      |> Posts.sort_posts(params)
      |> Poster.Repo.paginate(params)

    posts = Poster.Repo.preload(page.entries, [:author, :tags, :comments])
    {posts, page}
  end

  # TODO: Centralize these in a module
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
