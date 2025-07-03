# How to assign roles to user 

## Stage one 

- all user could read all posts
- user could only edit/update/delete post created by himself.
- admin can do anything 


### General steps one -- prepare roles and code interface function

1. create an new attribute `:role` on `hello.Accounts.User` resource. Default role is `:user`

```elixir 
# hello.Accounts.User
attribute :role, hello.Accounts.Role do
  allow_nil? false
  default :user
end
```

2. add a utility action to the `hello.Accounts.User` resource. A new update action that only allows settings the role attribute for a given user record.

```elixir 
# hello.Accounts.User
update :set_role do
  accept [:role]
end

```


3. add code interface for the new action to make it easier to run.

```elixir 
# hello.Accounts
resource hello.Accounts.User do
  define :set_user_role, action: :set_role, args: [:role]
  define :get_user_role_by_id, action: :read, get_by: [:id]
end
```

we could set a user role by using `authorize?: false` option when call the interface function.

```elixir 
user = hello.Accounts.get_user_role_by_id(<uuid>, authorize?: false)
hello.Accounts.set_user_role(user, :admin, authorize?: false)
```


### General steps two -- create policies for resources

This will break the web interface completely, everything will be forbidden.

1. Config `Post` resource with `Ash.Policy.Authorizer` 

```elixir 
# hello.Documents.Post
  use Ash.Resource,
    domain: hello.Documents,
    data_layer: AshPostgres.DataLayer,
    # this will make ash to run policy checks for any action in this resource
    authorizers: [Ash.Policy.Authorizer]
```

Without any configuration, we will hit `Ash.Error.Forbidden at GET /`.

2. Define policies 

```elixir 
# hello.Documents.Post
  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action(:create_post) do
      authorize_if always()
    end
  end
```

The above policies does:

- allow admin to do anything 
- all actions with type `:read` is allowed 
- `:create_post` is allowed for `:user` role.


### General steps three -- Removing forbidden Actions from the UI.
We need to hidde the button or link if the user authorize failed to do so. 

1. Identifying the actor when calling actions
   
In `Post` related code interface, we need to include option: `actor: socket.assigns.current_user`.


2. Updating forms to identify the actor

Pass `actor: socket.assigns.current_user` and pipe with `AshPhoenix.Form.ensure_can_submit!()`.

```elixir 
 form =
   hello.Documents.form_to_update_post(post, actor: socket.assigns.current_user)
   |> AshPhoenix.Form.ensure_can_submit!()
```

3. Blocking pages from unauthorized access 
  
```elixir 
# helloWeb.LiveUserAuth
# This would allow us to write on_mount calls in a liveview like:
# on_mount {TunezWeb.LiveUserAuth, role_required: :admin}
def on_mount([role_required: role_required], _, _, socket) do
 current_user = socket.assigns[:current_user]

 if current_user && current_user.role == role_required do
   {:cont, socket}
 else
   socket =
     socket
     |> Phoenix.LiveView.put_flash(:error, "Unauthorized!")
     |> Phoenix.LiveView.redirect(to: ~p"/")

   {:halt, socket}
 end
end
```

4. Hiding calls to actions that the actor can't perform  

- Use `can_*? code interface functions` to update liveview.


### General steps four -- Write policy for post creator

We need to record who created and last modified a resource 
such that the only the user who created the post could edit or delete that post. 

1. Add new relationship on `Post` with `User` 

```elixir 
# hello.Documents.Post
  relationships do
    belongs_to :created_by, hello.Accounts.User
    belongs_to :updated_by, hello.Accounts.User
  end
```

- `mix ash.codegen add_user_links_to_posts`
- `mix ash.migrate`

2. Use `changes` block on `Post` resource to implement something like:
  "by the way, whenever you create or update a record, can you also store who made the change? Cheers."

```elixir 
# hello.Documents.Post
# This applies to all actions of
 type create and update.
  changes do
    change relate_actor(:created_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true)
  end
```

These changes mean that if we add more `:create` or `:update` actions to the `Post`
in future, they'll automatically have `created_by` and `updated_by` tracked

3. Update policy for `User` to enable action `:read`

**Notice**: Becaue we need to relate the actor to a record with `relate_actor`, we need to be able to read the actor from the database. 

```elixir 
# hello.Accounts.User
 policy action(:read) do
   authorize_if expr(id == ^actor(:id))
 end
```

4. Update policy on `Post` 

```elixir 
# hello.Documents.Post
# such that only the user who created the post can update or destroy it
 policy action([:update, :destroy]) do
   authorize_if expr(^actor(:role) == :user and created_by_id == ^actor(:id))
 end
```