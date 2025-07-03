# How to Ash 

## Get Started with Ash and Phoenix 

```sh
mix ecto.drop && MIX_ENV=test mix ecto.drop
mix ash_postgres.create
mix ash_postgres.generate_migrations --name initial_migration
mix ash_postgres.migrate
```

## Add now resources and domain 

1. Create module for resources and domain. 
2. Add domain to `config.exs`.
3. Generate new migration files by: `mix ash.codegen create_documents_post`
4. Run `mix ash.setup` or `mix ash.migrate`


## Add liveview for resources 

```sh 
mix ash_phoenix.gen.live --domain hello.Documents --resource hello.Documents.Post
```

## Troubleshootings 

1. type "citext" does not exist

When, run `mix ash.setup, it shows error about:  type "citext" does not exist.

Solution:

```Elixir
# In hello.Repo.Migrations.InitialMigrationExtensions1:
# Make sure there are create extension statement for citext
def up do
 ...
 execute("CREATE EXTENSION IF NOT EXISTS \"citext\"")
end

def down do
 ...
 execute("DROP EXTENSION IF EXISTS \"citext\"")
end
```

Then: 

- delete folder `resource_snapshots/repo`.
- run following commands in order.

```sh 
mix ecto.drop && MIX_ENV=test mix ecto.drop
mix ash_postgres.create
mix ash_postgres.generate_migrations --name initial_migration
mix ash_postgres.migrate
```


## References 

- [Get Started with Ash and Phoenix](https://hexdocs.pm/ash_phoenix/2.0.0-rc.1/getting-started-with-ash-and-phoenix.html)