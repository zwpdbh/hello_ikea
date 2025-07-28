defmodule Hello.Chat.Message do
  use Ash.Resource,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "messages"
    repo Hello.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :content, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :conversation, Hello.Chat.Conversation
  end
end
