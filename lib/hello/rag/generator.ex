defmodule Hello.Rag.Generator do
  require Logger

  defp generate_prompt(query) do
    {:ok, sections} = Hello.Rag.search_section(%{query: query})

    context =
      sections
      |> Enum.map(fn %Hello.Rag.Section{chunk: chunk} ->
        """
        [...]
        #{chunk}
        [...]
        """
      end)
      |> Enum.join("\n\n")

    """
    <|system|>
    You are a helpful assistant.<|end|>
    <|user|>
    Context information is below.
    ---------------------
    #{context}
    ---------------------
    Given the context information above, answer the following query concisely.
    Query: #{query} <|end|>
    <|assistant|>
    """
  end

  def generate_response(query) do
    prompt = generate_prompt(query)

    Nx.Serving.batched_run(MyLLMServing, prompt)
    |> Enum.map(&to_string/1)
    |> Enum.join()
  end

  def generate_response_stream(query, stream: callback) do
    prompt = generate_prompt(query)

    Nx.Serving.batched_run(MyLLMServing, prompt)
    |> Stream.each(callback)
    |> Stream.run()

    # Signal completion explicitly
    callback.(:done)
  end
end
