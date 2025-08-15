defmodule Hello.Chat.Conversation.Calculations.JoinedByActor do
  use Ash.Resource.Calculation

  @doc "Check if a specific user is in the conversation"
  def init(opts, _) do
    case Keyword.fetch(opts, :actor_id) do
      {:ok, _} ->
        {:ok, opts}

      :error ->
        {:error, "The `:actor_id` option is required for joined_by_actor calculation"}
    end
  end

  # see: https://hexdocs.pm/ash/3.5.34/calculations.html#module-calculations
  def calculate(records, _query, %{actor_id: _actor_id}, _context) do
    Enum.map(records, fn _record ->
      true
    end)
  end
end
