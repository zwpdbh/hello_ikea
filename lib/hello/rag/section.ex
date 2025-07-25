defmodule Hello.Rag.Section do
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
