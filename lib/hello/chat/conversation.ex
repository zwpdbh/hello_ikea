defmodule Hello.Chat.Conversation do
  use Ash.Resource,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "conversations"
    repo Hello.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    has_many :messages, Hello.Chat.Message
  end
end
