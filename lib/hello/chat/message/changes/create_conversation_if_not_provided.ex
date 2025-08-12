defmodule Hello.Chat.Message.Changes.CreateConversationIfNotProvided do
  require Logger
  use Ash.Resource.Change

  require Ash.Query

  @impl true
  def change(changeset, _opts, context) do
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
  end

  # @impl true
  # def change(changeset, _opts, context) do
  #   case {Ash.Changeset.get_attribute(changeset, :sender_type),
  #         Ash.Changeset.get_argument(changeset, :conversation_id)} do
  #     {nil, nil} ->
  #       # This is the case user is just directed to the `/chats` page
  #       changeset

  #     {:user, nil} ->
  #       "create conversation" |> dbg()
  #       # If the message is initalized by user, but have not associated with an conversation:
  #       # 1. Create the conversation

  #       changeset
  #       # See: https://hexdocs.pm/ash/3.5.34/Ash.Changeset.html#before_action/3
  #       |> Ash.Changeset.before_action(fn changeset ->
  #         conversation = create_conversation(context.actor)

  #         # 2. Create manay to many relationship of User -- Conversation
  #         add_user_conversation_relationship(conversation.id, context.actor.id)

  #         # 3. Set the message attribute's conversation_id
  #         changeset
  #         |> set_message_conversation_id(conversation.id)
  #         |> set_message_from_user_by_actor(context.actor.id)
  #       end)

  #     {:user, conversation_id} ->
  #       "use existing conversation #{conversation_id}" |> dbg()

  #       changeset
  #       |> Ash.Changeset.before_action(fn changeset ->
  #         # If the message is initalized by user, and have already associated with an conversation:
  #         # 1. Create manay to many relationship of User -- Conversation
  #         add_user_conversation_relationship(conversation_id, context.actor.id)

  #         changeset
  #       end)
  #       |> set_message_conversation_id(conversation_id)
  #       |> set_message_from_user_by_actor(context.actor.id)
  #       |> dbg()

  #     {_other, nil} ->
  #       raise "the conversation but be initialized by :user"

  #     {_other, conversation_id} ->
  #       changeset
  #       |> set_message_conversation_id(conversation_id)
  #       |> set_message_from_user_by_actor(context.actor.id)
  #   end
  # end

  # defp add_user_conversation_relationship(conversation_id, user_id) do
  #   {:ok, _user_conversation} =
  #     Hello.Chat.UserConversation
  #     |> Ash.Changeset.for_create(:create, %{user_id: user_id, conversation_id: conversation_id})
  #     |> Ash.create()
  # end

  # defp create_conversation(user) do
  #   {:ok, conversation} =
  #     Hello.Chat.Conversation
  #     |> Ash.Changeset.for_create(:create, %{title: nil}, actor: user)
  #     |> Ash.create()

  #   conversation
  # end

  # defp set_message_conversation_id(changeset, conversation_id) do
  #   Ash.Changeset.force_change_attribute(changeset, :conversation_id, conversation_id)
  # end

  # defp set_message_from_user_by_actor(changeset, user_id) do
  #   Ash.Changeset.change_attribute(changeset, :sender_id, user_id)
  # end
end
