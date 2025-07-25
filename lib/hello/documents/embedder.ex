defmodule Hello.Documents.Embedder do
  def generate_embeddings(chunks) do
    chunk_text_list =
      chunks |> Enum.map(& &1.text)

    Nx.Serving.batched_run(MyEmbeddingServing, chunk_text_list)
    |> Enum.map(fn %{embedding: embedding} -> Nx.to_list(embedding) end)
  end
end

defmodule Hello.Documents.Embedder.Play do
  def generate_embeddings() do
    Hello.Documents.Loader.load()
    |> Hello.Documents.Chunker.chunk_with_metadata()
    |> Hello.Documents.Embedder.generate_embeddings()
  end
end
