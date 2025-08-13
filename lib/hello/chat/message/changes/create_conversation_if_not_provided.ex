defmodule Hello.Chat.Message.Changes.CreateConversationIfNotProvided do
  require Logger
  use Ash.Resource.Change

  require Ash.Query

  @impl true
  def change(changeset, _opts, context) do
    changeset |> dbg()
    context |> dbg()

    if changeset.arguments[:conversation_id] do
      Logger.warning(" ->> set conversation_id")

      Ash.Changeset.force_change_attribute(
        changeset,
        :conversation_id,
        changeset.arguments.conversation_id
      )
    else
      Logger.warning("->> before_action, prepare conversation")

      Ash.Changeset.before_action(changeset, fn changeset ->
        conversation = Hello.Chat.create_conversation!(Ash.Context.to_opts(context))

        Ash.Changeset.force_change_attribute(changeset, :conversation_id, conversation.id)
      end)
    end
  end
end
