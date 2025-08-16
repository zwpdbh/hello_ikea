defmodule Hello.Chat.Conversation do
  use Ash.Resource,
    domain: Hello.Chat,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "conversations"
    repo Hello.Repo
  end

  actions do
    defaults [:read, :destroy]

    read :my_conversations do
      pagination keyset?: true, required?: false

      filter expr(join_by_member(member_id: ^actor(:id)) == true)
    end

    create :create do
      accept [:title]
      primary? true
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

    # For a conversation, load all of its members
    # 1. first define a has many relationship for the join resource
    has_many :conversation_member_relationship, Hello.Chat.ConversationMember

    # 2. then define a many_to_many relationship using has_many relationship
    many_to_many :members, Hello.Accounts.User do
      join_relationship :conversation_member_relationship
      destination_attribute_on_join_resource :member_id
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

    calculate :join_by_member, :boolean do
      argument :member_id, :uuid do
        allow_nil? false
      end

      calculation expr(exists(conversation_member_relationship, member_id == ^arg(:member_id)))
    end
  end
end

defmodule Hello.Chat.Conversation.Play do
  def find_conversation_by_id() do
    Hello.Chat.Conversation
    |> Ash.Query.for_read(:read)
    |> Ash.read(authorize?: false)
  end
end
