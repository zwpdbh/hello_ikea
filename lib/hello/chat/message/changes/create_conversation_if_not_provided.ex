defmodule Hello.Chat.Message.Changes.CreateConversationIfNotProvided do
  use Ash.Resource.Change

  require Ash.Query

  @impl true
  def change(changeset, _opts, context) do
    changeset =
      case Ash.Changeset.get_attribute(changeset, :sender_type) do
        :user ->
          Ash.Changeset.change_attribute(changeset, :sender_id, context.actor.id)

        _ ->
          changeset
      end

    if changeset.arguments[:conversation_id] do
      Ash.Changeset.force_change_attribute(
        changeset,
        :conversation_id,
        changeset.arguments.conversation_id
      )
    else
      Ash.Changeset.before_action(changeset, fn changeset ->
        user_id = Ash.Changeset.get_attribute(changeset, :sender_id)

        {:ok, [user]} =
          Hello.Accounts.User
          |> Ash.Query.filter(id == ^user_id)
          |> Ash.read(authorize?: false)

        {:ok, conversation} =
          Hello.Chat.Conversation
          |> Ash.Changeset.for_create(:create, %{title: nil}, actor: user)
          |> Ash.create()
          |> dbg()

        {:ok, _user_conversation} =
          Hello.Chat.UserConversation
          |> Ash.Changeset.for_create(:create, %{
            user_id: user.id,
            conversation_id: conversation.id
          })
          |> Ash.create()

        Ash.Changeset.force_change_attribute(changeset, :conversation_id, conversation.id)
      end)
    end
  end
end
