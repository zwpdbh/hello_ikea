defmodule Hello.Documents.Outline do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:outline, {:array, :string})
  end

  def represent(%__MODULE__{} = item) do
    item.outline |> Enum.join("\n")
  end
end

defmodule Hello.Documents.Article do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:response, :string)
  end

  def represent(%__MODULE__{} = item) do
    item.response
  end
end
