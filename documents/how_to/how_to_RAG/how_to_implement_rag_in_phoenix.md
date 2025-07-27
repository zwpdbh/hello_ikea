#  How to implement rag in phoenix

## References 

- [Why Elixir/OTP doesn't need an Agent framework: Part 1](https://goto-code.com/blog/elixir-otp-for-llms/)
- [Why Elixir/OTP doesn't need an Agent framework: Part 2](https://goto-code.com/blog/elixir-otp-for-llms-part-2/)
- [I tried to build an AI product with LangChain, Vue 3, Svelte 5 with Phoenix LiveView, so you don’t have to.](https://blog.creativefoundry.ai/i-tried-to-build-an-ai-product-with-langchain-vue-3-svelte-5-with-phoenix-liveview-so-you-dont-134930c78342)
  - [Inertia.js Phoenix Adapter](https://github.com/inertiajs/inertia-phoenix)
  - [Instructor allows you to get structured output out of an LLM using Ecto.](https://github.com/thmsmlr/instructor_ex)
- [The Unfaltering Machine: Why AI Reinforces the Fundamental Truth of Elixir](https://medium.com/@matheuscamarques/the-unfaltering-machine-why-ai-reinforces-the-fundamental-truth-of-elixir-8dfd71ccb439) 
- [Using LLMs and AI Agents to super power your Phoenix apps](https://www.youtube.com/watch?v=Hnpt2zv0rVw)
- [LLMs & Elixir: Windfall or Deathblow?](https://www.zachdaniel.dev/p/llms-and-elixir-windfall-or-deathblow)
  - [reddit discussion](https://news.ycombinator.com/item?id=44186496)
- [The Remote AI Runtime for Phoenix](https://phoenix.new/)
  - [Keynote: Code Generators are Dead. Long Live Code Generators - Chris McCord | ElixirConf EU 2025](https://www.youtube.com/watch?v=ojL_VHc4gLk)

### RAG

- [Retrieval-Augmented Generation (RAG) with Elixir](https://shapath.com.np/posts/beginning-rag-elixir/)
  - This post introduce how to use plain elixir to build RAG system with following libraries 
  
    ```elixir 
      {:text_chunker, "~> 0.3.1"},
      {:pgvector, "~> 0.3.0"},
      {:bumblebee, "~> 0.4.2"},
      {:exla, "~> 0.6"},
      {:nx, "~> 0.6"},
      {:ollama, "0.7.0"}
    ```

- RAG with Elixir series
  - [How even the simplest RAG can empower your team](https://bitcrowd.dev/how-even-the-simplest-RAG-can-empower-your-team/)
  - [A RAG for Elixir](https://bitcrowd.dev/a-rag-for-elixir/)
  - [A RAG for Elixir in Elixir](https://bitcrowd.dev/a-rag-for-elixir-in-elixir/)
    
    see [corresponding livebook demo](https://gist.github.com/joelpaulkoch/9192abd23bd2e6ff76be314c24173974), notice its dependencies related with RAG 
      
    ```elixir 
    {:chroma, "~> 0.1.3"},
    {:text_chunker, "~> 0.3.1"},
    {:nx, "~> 0.9.0"},
    {:exla, "~> 0.9.1"},
    {:axon, "~> 0.7.0"},
    {:bumblebee, github: "joelpaulkoch/bumblebee", branch: "jina-embeddings-v2-base-code"}
    ```

  - [A RAG Library for Elixir](https://bitcrowd.dev/a-rag-library-for-elixir/?utm_source=elixir-merge)
    - Follow this post, you could enhance an LLM chat app with RAG feature.
    - [Rag -- A library to build RAG (Retrieval Augmented Generation) systems in Elixir.](https://hexdocs.pm/rag/Rag.html)  
      - This is the `Rag` lib `bitcrowd` introduced.
  - BTW, the `bitcrowd` page layout is good. 

## My RAG exloration 

- Common libs I need 

```elixir 
{:text_chunker, "~> 0.3.1"}, #  segmenting large text documents, optimizing them for efficient embedding
{:pgvector, "~> 0.3.0"},  # save embedding vectors 
{:bumblebee, "~> 0.4.2"}, # use pre-trained Neural Network models -- local LLM model 
{:axon, "~> 0.7.0"}, # if we don't use `ollama`
{:exla, "~> 0.6"}, # for axon
{:nx, "~> 0.6"}, # axon
{:ollama, "0.7.0"}, # do I need this to run LLM model locally? What feature it provides?
```