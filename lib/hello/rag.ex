defmodule Hello.Rag do
  use Ash.Domain

  resources do
    resource Hello.Rag.Section do
      define :create_section, action: :create
      define :read_section, action: :read
      define :search_section, action: :search_section
    end
  end
end

defmodule Hello.Rag.Play do
  def generate_embeddings_and_save() do
    Hello.Rag.Loader.load()
    |> Hello.Rag.Chunker.chunk_with_metadata()
    |> Hello.Rag.Embedder.generate_embeddings()
    |> Hello.Rag.Embedder.store_embeddings_and_chunks()
  end

  def search_section(query) do
    Hello.Rag.Generator.generate_response(query)
  end
end
