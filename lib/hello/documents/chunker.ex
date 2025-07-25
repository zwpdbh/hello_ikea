# references:
# 1. https://bitcrowd.dev/a-rag-for-elixir-in-elixir/#ingestion
# 2. https://hexdocs.pm/bumblebee/llms_rag.html#generating-embeddings

defmodule Hello.Documents.Chunker do
  defmodule Chunk do
    defstruct [
      :source,
      :start_byte,
      :end_byte,
      :text
    ]
  end

  @spec chunk_with_metadata([%{source: String.t(), content: String.t()}]) :: any()
  def chunk_with_metadata(documents) do
    documents
    |> Enum.map(&chunk_one_document_with_metadata/1)
    |> List.flatten()
  end

  defp chunk_one_document_with_metadata(%{source: file_source, content: file_content}) do
    TextChunker.split(file_content, format: format_from_file_extension(file_source))
    |> Enum.map(fn each_chunk ->
      %Chunk{
        source: file_source,
        start_byte: each_chunk.start_byte,
        end_byte: each_chunk.end_byte,
        text: each_chunk.text
      }
    end)
  end

  defp format_from_file_extension(file_source) do
    case Path.extname(file_source) do
      ".livemd" -> :markdown
      ".md" -> :markdown
      ".ex" -> :elixir
      ".exs" -> :elixir
      ".heex" -> :elixir
      _ -> :text
    end
  end
end

defmodule Hello.Documents.Chunker.Play do
  def load_document_and_generate_embedding() do
    Hello.Documents.Loader.load()
    |> Hello.Documents.Chunker.chunk_with_metadata()
  end
end
