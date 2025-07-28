defmodule Hello.Chat do
  use Ash.Domain

  resources do
    resource Hello.Chat.Conversation
    resource Hello.Chat.Message
  end
end
