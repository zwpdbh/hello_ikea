defmodule Hello.Documents.TopicClassification do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:domain, Ecto.Enum, values: [:entertainment, :science, :finance])
    field(:search_terms, :string)
  end
end

defmodule Hello.Documents.Summary do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:summary, :string)
    field(:key_points, {:array, :string})
  end
end
