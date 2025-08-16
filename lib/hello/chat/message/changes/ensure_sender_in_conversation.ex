defmodule Hello.Chat.Message.Changes.EnsureSenderInConversation do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, result ->
      %Hello.Chat.Message{sender_id: sender_id, conversation_id: conversation_id} = result

      user =
        Hello.Accounts.User
        |> Ash.get!(sender_id, authorize?: false)

      {:ok, conversation} =
        Hello.Chat.Conversation
        |> Ash.get!(conversation_id, authorize?: false)
        |> Ash.load(join_by_member: %{member_id: user.id})

      if not conversation.join_by_member do
        {:ok, _} = Hello.Chat.join_conversation(conversation, actor: user, authorize?: false)
      end

      {:ok, result}
    end)
  end
end
