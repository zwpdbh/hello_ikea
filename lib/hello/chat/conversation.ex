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
      pagination keyset?: true, required?: false
      # filter expr(exists(user_conversations, user_id == ^actor(:id)))
    end

    create :create do
      accept [:title]
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

    many_to_many :users, Hello.Accounts.User do
      through Hello.Chat.UserConversation
      source_attribute_on_join_resource :conversation_id
      destination_attribute_on_join_resource :user_id
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

defmodule Hello.Chat.Conversation.Play do
  require Ash.Query

  def load_one_user_conversations() do
    current_user = nil
    Hello.Chat.my_conversations!(actor: current_user, stream?: true)
  end

  def load_all_conversations() do
    Hello.Chat.Conversation
    |> Ash.Query.load(:users)
    |> Ash.read!(authorize?: false)
  end
end
