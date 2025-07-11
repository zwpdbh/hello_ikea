defmodule Hello.Documents.PerspectiveList do
  use Ecto.Schema
  use InstructorLite.Instruction

  @all_perspectives [
    :economic,
    :social,
    :ethical,
    :political,
    :historical,
    :technological,
    :environmental,
    :cultural,
    :legal,
    :philosophical,
    :scientific,
    :psychological,
    :global,
    :local
  ]

  @primary_key false
  embedded_schema do
    field(:persectives, {:array, Ecto.Enum}, values: @all_perspectives)
  end
end

defmodule Hello.Documents.PerspectiveList.ArrayResponse do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:perspective, :string)
    field(:analysis_type, Ecto.Enum, values: [:support, :counter, :biases])
  end
end

defmodule Hello.Documents.PerspectiveList.EssayOutline do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:title, :string)
    field(:introduction, :string)
    field(:sections, {:array, :string})
    field(:conclusion, :string)
    field(:balanced_approach_notes, :string)
  end
end

defmodule Hello.Documents.PerspectiveList.Runner do
  @doc """
  Runs multiple LLM tasks in parallel and collects their results.

  ## Example

    Runner.parallel([
      fn -> create_outline(messages, topic) end,
      fn -> generate_keywords(topic) end
    ])
  """
  def parallel(task_fns, timeout \\ 30_000) do
    task_fns
    |> Enum.map(&Task.async/1)
    |> Task.await_many(timeout)
  end
end
