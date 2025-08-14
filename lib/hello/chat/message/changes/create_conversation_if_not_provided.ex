defmodule Hello.Chat.Message.Changes.CreateConversationIfNotProvided do
  require Logger
  use Ash.Resource.Change

  require Ash.Query

  @impl true
  def change(changeset, _opts, context) do
    # changeset |> dbg()
    # context |> dbg()

    changeset =
      if changeset.arguments[:conversation_id] do
        Ash.Changeset.force_change_attribute(
          changeset,
          :conversation_id,
          changeset.arguments.conversation_id
        )
      else
        Ash.Changeset.before_action(changeset, fn changeset ->
          conversation = Hello.Chat.create_conversation!(Ash.Context.to_opts(context))
          Ash.Changeset.force_change_attribute(changeset, :conversation_id, conversation.id)
        end)
      end

    changeset
  end
end
