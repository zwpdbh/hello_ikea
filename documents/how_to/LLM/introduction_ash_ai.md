# Introduction Ash AI 

## Related Features  

- Prompt-backed Actions with Structured Outputs

This is the feature LLM could give your structured output.

1. `use Ash.Type.NewType` define your model type. 
2. define action and specify the type. now call that action will produce typed structure!


- Tool defintion - A tool call is something that the agent can do to invoke some piece of functionality that your app provides.
- Vectorisation - How to use with RAG
- Complex/multi-agent workflows -- What is `Reactor`.

## Features I need to modify 

- In current chat, if I type some message, it automatically trigger the response from LLM.
  1. How to disable this?
  2. Create an avatar feature: 
      - when enable, a vartual me will use my post as context to generate response for me. 
      - when disable, I could just send message as normal user.  

- How to let response from LLM use my posts as context? 


## Questions 

Related with vectorization 
I am currently try to enable vecotorization search on `Post`. 

1. Params for `vector_cosine_distance`

```elixir 
 # different from :search such that it only search posts created by current actor
    read :my_posts do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      # This is how we use vectors
      # see: https://hexdocs.pm/ash_ai/readme.html#using-the-vectors
      prepare before_action(fn query, context ->
                case YourEmbeddingModel.generate([query.arguments.query], []) do
                  {:ok, [search_vector]} ->
                    Ash.Query.filter(
                      query,
                      vector_cosine_distance(full_text_vector, ^search_vector) < 0.5
                    )
                    |> Ash.Query.sort(
                      {calc(vector_cosine_distance(full_text_vector, ^search_vector),
                         type: :float
                       ), :asc}
                    )
                    |> Ash.Query.limit(10)

                  {:error, error} ->
                    {:error, error}
                end
              end)

      # argument can then be used in a filter
      filter expr(contains(title, ^arg(:query)) and created_by_id == ^actor(:id))
      pagination offset?: true, default_limit: 12
    end
```

- `full_text_vector` is not defined 
- so, how to call `vector_cosine_distance`


## References 

- [Ash AI: A comprehensive LLM toolbox for Ash Framework](https://alembic.com.au/blog/ash-ai-comprehensive-llm-toolbox-for-ash-framework)
  - [A Complete AI Toolkit: Ash AI Demo](https://www.youtube.com/watch?v=4dzZ44-xVds)
- [Ash AI -- documents](https://hexdocs.pm/ash_ai/readme.html)
- About LangChain
  - [LangChain Providers](https://python.langchain.com/docs/integrations/providers/)  
    - [ByteDance](https://python.langchain.com/docs/integrations/providers/byte_dance/)    
    - [Alibaba Cloud](https://python.langchain.com/docs/integrations/providers/alibaba_cloud/)
  - [LangChain is a framework for building LLM-powered applications.](https://github.com/langchain-ai/langchain)
  - [LangChain.js](https://github.com/langchain-ai/langchainjs)
  - [Elixir LangChain](https://github.com/brainlid/langchain)
- LLM APIs 
  - [deepseek -- API keys](https://platform.deepseek.com/api_keys)
  - [Doubao -- 火山引擎](https://console.volcengine.com/ark/region:ark+cn-beijing/)
    - model: `doubao-seed-1-6-250615`.
    - api endpoint: `https://ark.cn-beijing.volces.com/api/v3/chat/completions`
  - [Open AI -- API keys](https://platform.openai.com/usage)