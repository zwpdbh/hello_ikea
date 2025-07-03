# How to add pagination support
 

## General steps 

1.  Ash supports automatic pagination of read actions10 using the `pagination` macro, so update search action on `Post` resource: 

- Add `pagination` to `:search` action. 

```elixir 
read :search do
  argument :query, :ci_string do
    constraints allow_empty?: true
    default ""
  end

  # argument can then be used in a filter
  filter expr(contains(title, ^arg(:query)))
  pagination offset?: true, default_limit: 12
end
```

- Differences between `keyset` and `offset` pagination.

**Notice**: This will affect the return type of the `search` action. 
The list of posts resulting from running the text search is now wrapped up
in an `Ash.Page.Offset struct`,


2. Update liveview to use `Page` structure. 

- update `assign` for page. 

Previously:

```elixir 
posts =
  hello.Documents.search_posts!(query_text,
    query: [sort_input: sort_by],
    actor: socket.assigns.current_user
  )
```

Now: 

```elixir 
page = hello.Documents.search_posts!(query_text,
    query: [sort_input: sort_by],
    actor: socket.assigns.current_user
  )
```

Change `@posts` to `@page.results`

3. Add pagination links to the bottom of the catalog.

```elixir 
<.pagination_links page={@page} query_text={@query_text} sort_by={@sort_by} />
``` 

and `.pagination_link` component is using `AshPhoenix.LiveView` helper functions to inspect a `Page` struct to see:
- if there is a previous page.
- next page,
- what the current page is ...

```elixir 
def pagination_links(assigns) do
 ~H"""
 <div
   :if={AshPhoenix.LiveView.prev_page?(@page) || AshPhoenix.LiveView.next_page?(@page)}
   class="flex justify-center pt-8 space-x-4"
 >
   <.button_link
     data-role="previous-page"
     kind="primary"
     inverse
     patch={~p"/?#{query_string(@page, @query_text, @sort_by, "prev")}"}
     disabled={!AshPhoenix.LiveView.prev_page?(@page)}
   >
     « Previous
   </.button_link>
   <.button_link
     data-role="next-page"
     kind="primary"
     inverse
     patch={~p"/?#{query_string(@page, @query_text, @sort_by, "next")}"}
     disabled={!AshPhoenix.LiveView.next_page?(@page)}
   >
     Next »
   </.button_link>
 </div>
 """
end
```

At this point:

- the liveview should show the pagination links (if there are enough data).
- click `Next` will update the url query string with `limit` and `offset` parameters. But we still only see the first page of posts.

4. Use `limit` and `offset` query parameter. 
 
Update how we `search_posts` by adding additional `:page` parameter.

```elixir 
 page =
   hello.Documents.search_posts!(query_text,
     query: [sort_input: sort_by],
     page: page_params,
     actor: socket.assigns.current_user
   )
```

## References 
- Pagination of Search Results -- Ch03 of Ash Framework 