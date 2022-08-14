defmodule PosterWeb.PostLive.Show do
  @moduledoc false

  use PosterWeb, :live_view
  on_mount {PosterWeb.LiveAuth, :fetch_user}

  @topic "comments"

  alias Poster.Posts
  alias Poster.Markdown
  alias Poster.Posts.{Comment, Post}

  @impl true
  def mount(_params, _session, socket) do
    PosterWeb.Endpoint.subscribe(@topic)

    {:ok,
     assign(socket,
       changeset: Posts.change_comment(%Comment{})
     )}
  end

  @impl true
  def handle_params(%{"slug" => slug} = params, _, socket) do
    post = Posts.get_post_by_slug!(slug, [:tags, :author])
    markdown = Markdown.to_html!(post.body)

    comments_page =
      Posts.post_comments(post)
      |> Poster.Repo.paginate(params)

    comments = Poster.Repo.preload(comments_page.entries, :author)

    {:noreply,
     socket
     |> assign(:page_title, post.title)
     |> assign(:post, post)
     |> assign(:comments, comments)
     |> assign(:page, comments_page)
     |> assign(:rendered_markdown, markdown)}
  end

  @impl true
  def handle_event("validate", %{"comment" => params}, socket) do
    changeset =
      %Comment{}
      |> Posts.change_comment(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"comment" => params}, socket) do
    post = socket.assigns.post

    comment =
      case socket.assigns.current_user do
        nil -> Posts.create_comment(params, post)
        user -> Posts.create_comment_with_author(params, post, user.author)
      end

    case comment do
      {:ok, comment} ->
        PosterWeb.Endpoint.broadcast_from!(self(), @topic, "new_comment" <> comment.id, comment)

        {:noreply,
         assign(socket,
           comments: [comment | socket.assigns.comments],
           changeset: Posts.change_comment(%Comment{})
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info(%{topic: @topic, payload: comment}, socket) do
    comment = Poster.Repo.preload(comment, :author)

    comments =
      if socket.assigns.page.page_number < 2 do
        [comment | socket.assigns.comments]
      else
        socket.assigns.comments
      end

    {:noreply, assign(socket, :comments, comments)}
  end

  defp safe_html(html_body) do
    {:safe, sanitized} = sanitize(html_body)
    sanitized
  end

  defp author_name(%Post{} = post) do
    case post.author_id do
      nil -> "Anonymous"
      _ -> post.author.name
    end
  end

  defp author_name(%Comment{} = comment) do
    case comment.author_id do
      nil -> "Anonymous"
      _ -> comment.author.name
    end
  end

  defp format_post_date(datetime) do
    Timex.format!(datetime, "%Y-%m-%d %H:%M", :strftime)
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

  defp is_owner?(author, post) do
    post.author_id == author.id
  end

  defp render_tags(tags) do
    for(tag <- tags, do: tag.title) |> Enum.join(", ")
  end

  defp relative_comment_date(time) do
    Timex.format!(time, "{relative}", :relative)
  end
end
