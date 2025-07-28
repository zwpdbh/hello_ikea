defmodule Hello.Rag.Generator do
  def generate_response(query) do
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

    prompt =
      """
      <|system|>
      You are a helpful assistant.</s>
      <|user|>
      Context information is below.
      ---------------------
      #{context}
      ---------------------
      Given the context information and no prior knowledge, answer the query concisely.
      Query: #{query}
      Answer: </s>
      <|assistant|>
      """

    Nx.Serving.batched_run(MyLLMServing, prompt)
  end
end
