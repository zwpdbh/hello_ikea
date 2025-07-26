defmodule Hello.Rag.Section do
  require Ash.Query

  use Ash.Resource,
    otp_app: :hello,
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
      # prepare before_action(&search_section/2)
      prepare before_action(fn query, context ->
                %{query: ash_query} = query.arguments
                query_string = Ash.CiString.value(ash_query)

                {:ok, query_embedding_vector} =
                  Hello.Rag.Embedder.generate_embedding(query_string)

                Ash.Query.filter(
                  query,
                  expr(vector_cosine_distance(embedding, ^query_embedding_vector) < 0.5)
                )
                |> Ash.Query.sort(
                  {calc(vector_cosine_distance(embedding, ^query_embedding_vector),
                     type: :float
                   ), :asc}
                )
                |> Ash.Query.limit(5)
              end)
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
