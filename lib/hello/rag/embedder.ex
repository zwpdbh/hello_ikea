defmodule Hello.Rag.Embedder do
  def generate_embeddings(chunks) do
    chunk_text_list =
      chunks |> Enum.map(& &1.text)

    embeddings =
      Nx.Serving.batched_run(MyEmbeddingServing, chunk_text_list)
      |> Enum.map(fn %{embedding: embedding} -> Nx.to_list(embedding) end)

    {chunks, embeddings}
  end

  def store_embeddings_and_chunks({chunks, embeddings}) do
    Enum.zip(chunks, embeddings)
    |> Enum.each(fn {chunk, embedding} ->
      chunk_map = Map.from_struct(chunk)
      metadata = Map.drop(chunk_map, [:text])

      Hello.Rag.create_section!(%{
        chunk: chunk_map.text,
        embedding: embedding,
        metadata: metadata
      })
    end)
  end
end

defmodule Hello.Rag.Embedder.Play do
  def generate_embeddings_and_save() do
    Hello.Rag.Loader.load()
    |> Hello.Rag.Chunker.chunk_with_metadata()
    |> Hello.Rag.Embedder.generate_embeddings()
    |> Hello.Rag.Embedder.store_embeddings_and_chunks()
  end
end
