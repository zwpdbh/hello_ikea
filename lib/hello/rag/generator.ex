defmodule Hello.Rag.Generator do
  require Logger

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

  def generate_response_stream(query, stream: callback) do
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
    |> Stream.each(callback)
    |> Stream.run()

    # Signal completion explicitly
    callback.(:done)
  end
end
