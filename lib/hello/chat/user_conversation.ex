defmodule Hello.Chat.UserConversation do
  use Ash.Resource,
    otp_app: :hello,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "user_conversations"
    repo Hello.Repo

    references do
      reference :user, on_delete: :delete, index?: true
      reference :conversation, on_delete: :delete
    end
  end

  actions do
    defaults [:read]

    create :create do
      accept [:user_id, :conversation_id]
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
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
