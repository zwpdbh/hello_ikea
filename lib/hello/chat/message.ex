defmodule Hello.Chat.Message do
  use Ash.Resource,
    otp_app: :hello,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "messages"
    repo Hello.Repo

    references do
      reference :conversation, index?: true
    end
  end

  actions do
    read :for_conversation do
      pagination keyset?: true, required?: false
      argument :conversation_id, :uuid, allow_nil?: false

      prepare build(default_sort: [inserted_at: :desc])
      filter expr(conversation_id == ^arg(:conversation_id))
    end

    create :create do
      accept [:content]

      argument :conversation_id, :uuid do
        allow_nil? true
        public? false
      end

      argument :sender, :map do
        description "The user who is sending the message"
        allow_nil? false
        public? false
      end

      change Hello.Chat.Message.Changes.CreateConversationIfNotProvided
      change manage_relationship(:sender, :sender, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :content, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :conversation, Hello.Chat.Conversation do
      public? true
      allow_nil? false
    end

    belongs_to :sender, Hello.Accounts.User do
      public? true
      allow_nil? false
      source_attribute :sender_id
    end
  end
end
