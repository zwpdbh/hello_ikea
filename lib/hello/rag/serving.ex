defmodule Hello.Rag.Serving do
  def build_embedding_serving() do
    repo = {:hf, "thenlper/gte-small"}
    {:ok, model_info} = Bumblebee.load_model(repo)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(repo)

    Bumblebee.Text.TextEmbedding.text_embedding(model_info, tokenizer,
      compile: [batch_size: 64, sequence_length: 512],
      defn_options: [compiler: EXLA, type: :f16],
      output_attribute: :hidden_state,
      output_pool: :mean_pooling
    )
  end

  def build_llm_serving() do
    repo = {:hf, "microsoft/phi-3.5-mini-instruct"}

    {:ok, model_info} = Bumblebee.load_model(repo)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(repo)
    {:ok, generation_config} = Bumblebee.load_generation_config(repo)

    generation_config = Bumblebee.configure(generation_config, max_new_tokens: 512)

    Bumblebee.Text.generation(model_info, tokenizer, generation_config,
      compile: [batch_size: 1, sequence_length: 1024],
      defn_options: [compiler: EXLA, type: :f16],
      stream: false
    )
  end
end

# Example from: How to use Jina embeddings in Elixir with Bumblebee
# ref: https://bitcrowd.dev/how-to-run-jina-embeddings-in-elixir/
defmodule Hello.Rag.Serving.Play do
  def load_bumblebee_model() do
    repo = {:hf, "thenlper/gte-small"}
    Bumblebee.load_model(repo)
  end
end
