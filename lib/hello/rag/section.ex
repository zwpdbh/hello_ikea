defmodule Hello.Rag.Section do
  require Ash.Query
  require Ash.Resource.Preparation.Builtins

  use Ash.Resource,
    domain: Hello.Rag,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sections"
    repo Hello.Repo

    custom_indexes do
      index "embedding vector_cosine_ops",
        name: "embeddings_index",
        using: "hnsw"
    end
  end

  actions do
    create :create do
      accept [:chunk, :metadata, :embedding]
    end

    read :search_section do
      argument :query, :ci_string do
        constraints allow_empty?: false
      end

      # see: https://hexdocs.pm/ash/3.5.32/Ash.Query.html#before_action/3
      prepare before_action(&Hello.Rag.Embedder.search_embedding/2)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :chunk, :string
    attribute :metadata, :map

    attribute :embedding, :vector do
      constraints dimensions: 384
    end

    timestamps(type: :utc_datetime)
  end
end
