defmodule Poster.PostsTest do
  use Poster.DataCase

  alias Poster.Posts

  describe "posts" do
    alias Poster.Posts.Post
    alias Poster.Blog.Author
    alias Poster.Tags.Tag

    import Poster.PostsFixtures
    import Poster.BlogFixtures

    @invalid_attrs %{body: nil, title: nil}
    @valid_attrs %{
      body: "some body once told me the world",
      title: "some title",
      tags_raw: "games, music"
    }
    @update_attrs %{
      body: "some updated body",
      title: "some updated title",
      tags_raw: "fun, things, big, loud, worker, bees"
    }

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      [fetched_post] = Posts.list_posts() |> Repo.all()

      assert fetched_post.id == post.id
      assert fetched_post.body == post.body
      assert fetched_post.title == post.title
    end

    test "list_posts/1 can query for search terms" do
      post_fixture()
      assert [_] = Posts.list_posts("games") |> Repo.all()
      assert [_] = Posts.list_posts("title") |> Repo.all()
      assert [_] = Posts.list_posts("told me the world") |> Repo.all()
      assert [] = Posts.list_posts("nonsense") |> Repo.all()
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      fetched_post = Posts.get_post!(post.id)
      assert post.id == fetched_post.id
      assert post.title == fetched_post.title
    end

    test "get_post_by_slug!/1 returns the post with given slug" do
      post = post_fixture()
      post_by_slug = Posts.get_post_by_slug!(post.slug)

      assert post.id == post_by_slug.id
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Posts.create_post(@valid_attrs, [:tags])
      assert post.body == "some body once told me the world"
      assert post.title == "some title"
      assert [%Tag{title: "games"}, %Tag{title: "music"}] = post.tags
    end

    test "create_post/1 - post must have at leaset 2 tags" do
      attrs = %{@valid_attrs | tags_raw: "single tag"}
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(attrs)
    end

    test "create_post/1 with valid thumbnail adds thumbnail to it" do
      thumb_url = "http://test.thumbnail.com/thumb.svg"

      attrs =
        Map.merge(@valid_attrs, %{
          body: """
          some body once told me the world

          ![thumb](#{thumb_url})
          """
        })

      assert {:ok, %Post{} = post} = Posts.create_post(attrs)
      assert post.thumbnail_url == thumb_url
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "create_post_with_author/2 associates post with an author" do
      author = author_fixture(%{name: "create_post/2"})

      assert {:ok, %Post{author: %Author{name: "create_post/2"}}} =
               Posts.create_post_with_author(@valid_attrs, author)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()

      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.body == "some updated body"
      assert post.title == "some updated title"

      # updates tag
      %Post{tags: [tag | _]} = Repo.preload(post, :tags)
      assert tag.title == "fun"
    end

    test "update_post/2 updates post thumbnail" do
      post = post_fixture()
      thumb_url = "http://test.thumbnail.com/completely_new_image_omg.svg"

      attrs =
        Map.merge(@update_attrs, %{
          body: """
          some updated body once told me the world

          ![thumb](#{thumb_url})
          """
        })

      assert {:ok, %Post{} = post} = Posts.update_post(post, attrs)
      assert post.thumbnail_url == thumb_url
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert fetched_post = Posts.get_post!(post.id)

      assert fetched_post.title == post.title
      assert fetched_post.body == post.body
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    test "deleting a post's tag does not deletes the post" do
      post = post_fixture()
      post.tags |> hd() |> Repo.delete!()

      assert Posts.get_post!(post.id)
    end
  end

  # describe "posts - sorting" do
  #   import Poster.PostsFixtures

  #   alias Poster.Posts.Post

  #   defp create_thirty_posts(_) do
  #     posts = for _ <- 1..30, do: post_fixture()
  #     %{posts: posts}
  #   end

  #   setup [:create_thirty_posts]

  #   test "sort_posts/2 accepts :new sorter" do
  #     asc_results = Posts.sort_posts(Post, {:new, :asc}) |> Repo.all()
  #     assert is_sorted?(asc_results, & &1.inserted_at)

  #     desc_results = Posts.sort_posts(Post, {:new, :desc}) |> Repo.all()
  #     refute is_sorted?(desc_results, & &1.inserted_at)
  #   end

  #   test "sort_posts/2 accepts :recently_updated sorter" do
  #     query = Posts.list_posts()

  #     query_results =
  #       Posts.sort_posts(query, {:recently_updated, :asc})
  #       |> Repo.all()

  #     assert is_sorted?(query_results, & &1.updated_at)

  #     query_results =
  #       Posts.sort_posts(query, {:recently_updated, :desc})
  #       |> Repo.all()

  #     refute is_sorted?(query_results, & &1.updated_at)
  #   end
      # defp is_sorted?(enum, by) do
      #   enum |> Enum.sort_by(by) |> only_ids() == only_ids(enum)
      # end

      # defp only_ids(enum), do: Enum.map(enum, & &1.id)
  # end

  describe "comments" do
    alias Poster.Posts.Comment
    alias Poster.Blog.Author

    import Poster.PostsFixtures
    import Poster.BlogFixtures

    @invalid_attrs %{body: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      [fetched_comment] = Posts.list_comments()

      assert fetched_comment.id == comment.id
      assert fetched_comment.body == comment.body
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      fetched_comment = Posts.get_comment!(comment.id)

      assert fetched_comment.id == comment.id
      assert fetched_comment.body == comment.body
    end

    test "create_comment/2 with valid data creates a comment" do
      valid_attrs = %{body: "some body"}
      post = post_fixture()

      assert {:ok, %Comment{} = comment} = Posts.create_comment(valid_attrs, post)
      assert comment.body == "some body"
    end

    test "create_comment/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.create_comment(@invalid_attrs, post)
    end

    test "create_comment_with_author/3 associates an author with the comment" do
      valid_attrs = %{body: "some body"}
      %Author{id: author_id} = author = author_fixture()
      post = post_fixture()

      assert {:ok, %Comment{author_id: ^author_id}} =
               Posts.create_comment_with_author(valid_attrs, post, author)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Comment{} = comment} = Posts.update_comment(comment, update_attrs)
      assert comment.body == "some updated body"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_comment(comment, @invalid_attrs)
      fetched_comment = Posts.get_comment!(comment.id) |> Poster.Repo.preload(:post)
      assert comment.id == fetched_comment.id
      assert comment.body == fetched_comment.body
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Posts.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Posts.change_comment(comment)
    end
  end
end
