# How to add search feature to liveview 

## Requirements 

- A search input field in the IndexLive for Post. Search on the titile of the post. 
- User select how to order the search result.  
- User can share the link the result of search -- meaning the url should reflect current search query and order.  

## General steps -- UI perspective 

1. Define a `search` action with argument for query in the `Post` resource. 
2. Expose Post's search action in the `Documents` code interface. 
3. Speeding search speed with custom database indexes 
   - Add `pg_trgm` extension on the `hello.Repo` 
   - In `Post` resource, create `custom_indexes` to index the title. 
   - `mix ash.codegen` and `mix ash.migrate` 
4. Integrate search into UI 
   - In `handle_params` extract `query_text`.
   - Load posts using exposed code interface function. 
   - Assign both `posts` and `query_text` to socket. 
   - Define a default `sort` method and assign it to socket as default value, user later will change this value from drop box selection.
   - Create component for `search_box` and use it in liveview. 

  At this stage:
  - A search box should show on the liveview.
  - User could type search string and press enter.
  - The browser's url should reflect the search like: `http://localhost:4000/?q=abcedsf`.
  - Modify browser's url like `http://localhost:4000/?q=abc` should also reflect changes on the liveview search box. \
  - Posts matches the search are filtered out and show in the liveview. 
  
5. Dynamically sorting 

   - modify UI to add search option drop box. When the option changed, it send out event `HANDLE EVENT "change-sort" in helloWeb.Posts.IndexLive`
   - update `handle_params` to assign `sort_by`
   - update `handle_event` from drop box, it will need to

6. Go back to liveview `handle_params` to get `sort_by` from `params`: `sort_by = Map.get(params, "sort_by") |> validate_sort_by()`.


The pattern: 
we have a default sort method defined, the user can change the selected value,
that value gets reflected back to them in the URL and on the page.

## General steps -- how to use the value updated from UI

The general idea is to to customize how we `query` posts resource. 

1. Mark `public? true` for the attribute you want to sort on. 
2. Update `handle_params` to use `sort_input` query when `search_posts`  

```elixir
posts =
  hello.Documents.search_posts!(query_text,
    query: [sort_input: sort_by],
    actor: socket.assigns.current_user
  )
```