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

    read :for_conversation do
      argument :conversation_id, :uuid do
        allow_nil? false
      end

      filter expr(conversation_id == ^arg(:conversation_id))
      pagination keyset?: true, required?: false
    end

    read :for_user do
      argument :user_id, :uuid do
        allow_nil? false
      end

      filter expr(user_id == ^arg(:user_id))
      pagination keyset?: true, required?: false
    end

    create :create do
      accept [:conversation_id]

      change relate_actor(:user, allow_nil?: false)
    end

    destroy :destroy do
      argument :conversation_id, :uuid do
        allow_nil? false
      end

      change filter expr(conversation_id == ^arg(:conversation_id) && user_id == ^actor(:id))
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:destroy) do
      authorize_if actor_present()
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
