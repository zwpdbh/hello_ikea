defmodule Hello.Chat.Message.Changes.EnsureSenderInConversation do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, result ->
      %Hello.Chat.Message{sender_id: sender_id, conversation_id: conversation_id} = result

      Hello.Chat.Conversation
      |> Ash.Query.calculate()

      {:ok, result}
    end)
  end
end
