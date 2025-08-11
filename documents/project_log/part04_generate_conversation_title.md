# Part04: Generate Conversation Title 

## Problem

Currently, when user send a message, it creates a corresponding conversation. 
But that conversation is missing title.

## Features 

- In sidebar, sort conversation by its last updated message. So, the conversation contains the latest message updated shows at the top. 
- If a conversation has no title generate its title by 
  - There are more than 3 messages.
  - Or, the conversation is created 10 mins from now. 
- In addition, add a `delete` button to conversation item to let user remove it from his conversation histories.
- Currently, one user has many conversations and one conversation `belongs_to` one user. 
  - To support multiple person's conversation, we need to change this such that one conversation has many users.


## Step01

- Modify UI to support delete conversation.

## Step02 

Modify model to add `many-to-many` relationships 

1. Generate join resource `Hello.Chat.UserConversation` to link `User` and `Conversation`.
2. Define `belongs_to` relationships
3. Add postgres `references` such that if user is delete or conversation is deleted, 
   we want to set the `on_delete` property of the foreign keys to delete all of the related links. 

```sh 
mix ash.gen.resource Hello.Chat.UserConversation --extend postgres
```
 
```elixir 
defmodule Hello.Chat.UserConversation do
  use Ash.Resource, otp_app: :hello, domain: Hello.Chat, data_layer: AshPostgres.DataLayer

  postgres do
    table "user_conversations"
    repo Hello.Repo

    references do
      reference :user, on_delete: :delete, index?: true
      reference :conversation, on_delete: :delete
    end
  end

  relationships do
    belongs_to :user, Hello.Accounts.User do
      primary_key? true
      allow_nil? false
    end

    belongs_to :conversation, Hello.Chat.Conversation do
      primary_key? true
      allow_nil? false
    end
  end
end
```

4. With join resource in place, we want define the many-to-many relationship we're after. 

From a user record, we could load all of their conversations. 
From a conversation, we could load all of the users.


For `Hello.Accounts.User`

- define `has_many` relationship for the join resource `Hello.Chat.UserConversation`
- define `many_to_many` relationship for `Hello.Chat.Conversation` 
  - `join_relationship`
  - `destination_attribute_on_join_resource`




## How to query many to many relationships 

- Given current actor, how to get all related conversations.
- Define a method on conversation to filter all conversations given an actor id.


## References 

- [Ash -- Manage Relationships](https://hexdocs.pm/ash/relationships.html#managing-relationships)
- [Part 4 — Ash Framework for Phoenix Developers — Relationshps 2/2](https://medium.com/@lambert.kamaro/part-4-ash-framework-for-phoenix-developers-relationshps-2-2-e87ad246a723)