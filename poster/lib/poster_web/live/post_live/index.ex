defmodule PosterWeb.PostLive.Index do
  @moduledoc false

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
  def handle_event("search", %{"query" => query}, socket) do
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
    |> assign(:query, Map.get(params, "query", nil))
    |> assign(:sorter, Map.get(params, "sorter", "New"))
    |> assign(:mode, Map.get(params, "mode", "Descending"))
  end

  defp list_posts(params) do
    page =
      params
      |> extract_search_term()
      |> Posts.list_posts()
      |> Posts.sort_posts(parse_sorting(params))
      |> Poster.Repo.paginate(params)

    posts = Poster.Repo.preload(page.entries, [:author, :tags, :comments])
    {posts, page}
  end

  defp extract_search_term(params) do
    with query <- get_in(params, ["query"]),
         true <- query != "" do
      query
    else
      _ -> nil
    end
  end

  defp parse_sorting(params) do
    sorter =
      case Map.get(params, "sorter") do
        "Recently updated" -> :recently_updated
        "New" -> :new
        _ -> :new
      end

    mode =
      case Map.get(params, "mode") do
        "Ascending" -> :asc
        "Descending" -> :desc
        _ -> :desc
      end

    {sorter, mode}
  end
end
