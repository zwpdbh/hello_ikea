defmodule Hello.Chat.Message do
  use Ash.Resource,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "messages"
    repo Hello.Repo
  end

  actions do
    read :for_conversation do
      pagination keyset?: true, required?: false
      argument :conversation_id, :uuid, allow_nil?: false

      prepare build(default_sort: [inserted_at: :desc])
      filter expr(conversation_id == ^arg(:conversation_id))
    end

    create :create do
      accept [:content, :sender_type, :sender_id]

      argument :conversation_id, :uuid do
        public? false
      end

      # see: https://hexdocs.pm/ash/Ash.Changeset.html
      change Hello.Chat.Message.Changes.CreateConversationIfNotProvided
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :content, :string do
      allow_nil? false
    end

    attribute :sender_type, :atom do
      allow_nil? false
      constraints one_of: [:user, :bot, :system]
    end

    attribute :sender_id, :uuid do
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    belongs_to :conversation, Hello.Chat.Conversation do
      public? true
      allow_nil? false
    end

    belongs_to :user, Hello.Accounts.User do
      public? true
      allow_nil? true
      source_attribute :sender_id
    end
  end
end
