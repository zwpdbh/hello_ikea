defmodule Hello.Chat.Message.Changes.EnsureSenderInConversation do
  use Ash.Resource.Change
  require Ash.Query

  alias Hello.Chat.UserConversation

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn changeset, message ->
      sender = Ash.Changeset.get_argument(changeset, :sender)
      sender_id = get_id(sender)
      conversation_id = message.conversation_id

      # Check if user is already in conversation
      exists? =
        UserConversation
        |> Ash.Query.filter(user_id == ^sender_id and conversation_id == ^conversation_id)
        |> Ash.exists?()

      if exists? do
        {:ok, message}
      else
        # Add user to conversation
        UserConversation
        |> Ash.Changeset.for_create(:create, %{
          user_id: sender_id,
          conversation_id: conversation_id
        })
        |> Ash.create(actor: %{id: sender_id})
        |> case do
          {:ok, _} ->
            {:ok, message}

          {:error, error} ->
            {:error, error}
        end
      end
    end)
  end

  defp get_id(%{id: id}), do: id
  defp get_id(id) when is_binary(id), do: id
end
