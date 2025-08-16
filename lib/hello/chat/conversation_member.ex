# It could be created from terminal by:
# `mix ash.gen.resource Hello.Chat.ConversationMember --extend postgres`
defmodule Hello.Chat.ConversationMember do
  use Ash.Resource,
    otp_app: :hello,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "conversation_members"
    repo Hello.Repo

    references do
      reference :conversation, on_delete: :delete, index?: true
      reference :member, on_delete: :delete
    end
  end

  actions do
    defaults [:read]
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end
  end

  relationships do
    belongs_to :conversation, Hello.Chat.Conversation do
      primary_key? true
      allow_nil? false
    end

    belongs_to :member, Hello.Accounts.User do
      primary_key? true
      allow_nil? false
    end
  end
end
