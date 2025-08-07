defmodule Hello.Chat.Conversation do
  use Ash.Resource,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "conversations"
    repo Hello.Repo
  end

  actions do
    defaults [:read]

    read :my_conversations do
      filter expr(user_id == ^actor(:id))
    end

    create :create do
      accept [:title]
      change relate_actor(:user)
    end

    update :update do
      accept [:title]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      public? true
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    has_many :messages, Hello.Chat.Message do
      public? true
    end

    belongs_to :user, Hello.Accounts.User do
      public? true
      allow_nil? false
    end
  end

  calculations do
    calculate :needs_title, :boolean do
      calculation expr(
                    is_nil(title) and
                      (count(messages) > 3 or
                         (count(messages) > 1 and inserted_at < ago(10, :minute)))
                  )
    end
  end
end
