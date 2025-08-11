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
        # since conversation and user is many to many relationship, so we need to set UserConversation for it.
        user_id = Ash.Changeset.get_attribute(changeset, :sender_id)

        _user =
          Hello.Accounts.User
          |> Ash.Query.filter(id == ^user_id)
          |> Ash.read!()
          |> dbg()

        conversation =
          context |> Ash.Context.to_opts() |> Hello.Chat.create_conversation!()

        Ash.Changeset.force_change_attribute(changeset, :conversation_id, conversation.id)
      end)
    end
  end
end
