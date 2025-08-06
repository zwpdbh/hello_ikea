defmodule Hello.Chat do
  use Ash.Domain

  resources do
    resource Hello.Chat.Conversation do
      define :create_conversation, action: :create
    end

    resource Hello.Chat.Message do
      define :create_message, action: :create
    end
  end
end
