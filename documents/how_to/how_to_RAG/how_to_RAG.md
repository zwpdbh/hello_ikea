# Phoenix RAG Implementation with Local LLM

## 1. **Local LLM Setup**

```elixir:mix.exs
{:bumblebee, "~> 0.4.2"},
{:axon, "~> 0.6.1"},
{:exla, "~> 0.6.1", only: :dev}
```

## 2. **Document Processing Pipeline** 

```elixir
defmodule RAG.DocumentProcessor do
  use Axon
  alias Bumblebee.Text.BartTokenizer
  
  def generate_embeddings(text_chunks) do
    {:ok, model} = Bumblebee.load_model({:hf, "sentence-transformers/all-mpnet-base-v2"})
    {:ok, tokenizer} = BartTokenizer.from_pretrained("facebook/bart-base")
    # ... embedding generation logic ...
  end
end
```

## 3. Vector Storage

```elixir 
defmodule MyApp.Repo.Migrations.CreateRagTables do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS vector"
    
    create table(:document_chunks) do
      add :content, :text
      add :embedding, :vector(768)
      add :metadata, :map
      timestamps()
    end

    create index(:document_chunks, ["embedding vector_cosine_ops"], using: "ivfflat")
  end
end
```

## 4. Retrieval Augmentation

```elixir 
defmodule RAG.Retriever do
  alias MyApp.Repo
  
  def semantic_search(query_embedding, top_k \\ 3) do
    from(dc in "document_chunks",
      select: [dc.content, fragment("embedding <=> ? as similarity", ^query_embedding)],
      order_by: fragment("similarity"),
      limit: ^top_k
    )
    |> Repo.all()
  end
end
```


## Inference Service

```elixir 
defmodule RAG.Inference do
  alias Bumblebee.Text.TextGeneration
  
  defp build_prompt(query, context_chunks) do
    """
    Using this testing handbook context:
    #{Enum.join(context_chunks, "\n---\n")}
    
    Answer this question about test failures:
    #{query}
    """
  end

  def generate_response(prompt) do
    {:ok, model} = Bumblebee.load_model({:hf, "mistralai/Mistral-7B-Instruct-v0.3"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "mistralai/Mistral-7B-Instruct-v0.3"})
    
    TextGeneration.generate(model, tokenizer, prompt,
      max_new_tokens: 1000,
      temperature: 0.3
    )
  end
end
```

If implement a hybrid approach with local embeddings + cloud LLM, using your private knowledge base with Doubao API:

```elixir 
defmodule RAG.Inference do
  defp build_prompt(query, context_chunks) do
    """
    Based strictly on this internal documentation:
    #{Enum.join(context_chunks, "\n---\n")}
    
    Respond to this user query:
    #{query}
    
    If unclear, say "I don't have information about that".
    """
  end

  def generate_response(prompt) do
    Req.post!("https://api.doubao.com/v1/chat/completions",
      json: %{
        model: "ernie-4.0",
        messages: [%{role: "user", content: prompt}],
        temperature: 0.3
      },
      headers: %{"Authorization" => "Bearer #{System.fetch_env!("DOUBAO_API_KEY")}"}
    )
    |> then(fn response ->
      response.body["choices"][0]["message"]["content"]
    end)
  end
end
```


## Implementation Notes

Recommended Models
- Embedding: sentence-transformers/all-mpnet-base-v2
- Generation: mistralai/Mistral-7B-Instruct-v0.3 (4-bit quantized)

## Performance Optimization

- Use EXLA with GPU acceleration
- Implement batch processing for embeddings
- Cache frequently accessed handbook sections
- Use IVFFlat indexes for fast similarity search

## Security Measures

- Sandbox LLM execution using :safe_fixtable
- Validate inputs with Ecto.Changeset
- Implement rate limiting

## Integration Flow
- User submits analysis request
- Generate query embedding
- Retrieve relevant context chunks
- Construct augmented prompt
- Generate and format LLM response