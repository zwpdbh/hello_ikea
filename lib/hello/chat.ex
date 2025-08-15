defmodule Hello.Chat do
  use Ash.Domain, extensions: [AshPhoenix]
  require Ash.Query

  resources do
    resource Hello.Chat.Conversation do
      define :create_conversation, action: :create
      define :my_conversations
      define :get_conversation, action: :read, get_by: [:id]
      define :destroy_conversation, action: :destroy
    end

    resource Hello.Chat.Message do
      define :create_message, action: :create

      define :message_history,
        action: :for_conversation,
        args: [:conversation_id],
        default_options: [query: [sort: [inserted_at: :desc]]]
    end

    resource Hello.Chat.UserConversation do
      define :users_for_conversation, action: :for_conversation, args: [:conversation_id]
      define :conversations_for_user, action: :for_user, args: [:user_id]

      define :join_conversation do
        action :create
        args [:conversation]

        custom_input :conversation, :struct do
          constraints instance_of: Hello.Chat.Conversation
          transform to: :conversation_id, using: & &1.id
        end
      end

      define :leave_conversation do
        action :destroy
        args [:conversation]

        get? true

        custom_input :conversation, :struct do
          constraints instance_of: Hello.Chat.Conversation
          transform to: :conversation_id, using: & &1.id
        end
      end
    end
  end

  @doc "List all conversations the user is a member of, using a manually built query."
  def my_conversations_manual() do
    Hello.Chat.Conversation
    # |> Ash.Query.filter(exists(user_conversations, user_id == ^actor_id))
    # |> Ash.Query.filter(joined_by_me == true)
    |> Ash.Query.sort(inserted_at: :desc, id: :desc)
    |> Ash.read!(authorize?: false)
  end

  @doc """
  Ecto.Adapters.SQL.query!(Hello.Repo, "SELECT * FROM user_conversations;")
  """
  def list_user_conversations() do
    Hello.Chat.UserConversation
    |> Ash.Query.limit(10)
    |> Ash.read!(authorize?: false)
  end
end
