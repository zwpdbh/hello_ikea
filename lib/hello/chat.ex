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

    resource Hello.Chat.ConversationMember
  end
end
