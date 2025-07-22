# How to integrate LLM with Phoenix

## Related libraries


## Discussed topics 

- [Is anyone working on “AI Agents” in Elixir?](https://elixirforum.com/t/is-anyone-working-on-ai-agents-in-elixir/69989/4)
- [Awesome Elixir LLM/GenAI](https://github.com/druyang/awesome-elixir-llm-genai)
- [Sean Moriarity – LLMs in production with Elixir](https://www.youtube.com/watch?v=BWszj-i1NJ4)
  - [ElixirConf 2023 - Sean Moriarity - MLOps in Elixir: Simplifying traditional MLOps with Elixir](https://www.youtube.com/watch?v=6aVnwj8WQq4)


## References 

- [Elixir LangChain](https://github.com/brainlid/langchain)
- [Jido (自動)](https://github.com/agentjido/jido)
- [Bumblebee](https://hexdocs.pm/bumblebee/Bumblebee.html)
- [Axon](https://hexdocs.pm/axon/0.7.0/Axon.html)
- [instructor_ex](https://github.com/thmsmlr/instructor_ex)

### Elixir LLM Library Comparison for RAG Implementation

| Library       | Purpose                          | RAG Relevance | Key Differentiator                 |
|---------------|----------------------------------|---------------|-------------------------------------|
| **Bumblebee** | Pre-trained model integration    | Essential     | Native HuggingFace model execution  |
| **Axon**      | Neural network construction      | Optional      | Flexible model customization        |
| **instructor**| Structured output generation    | Complementary | Type-safe LLM response validation   |
| **Jido**      | Autonomous AI agents             | Peripheral    | Agent-to-agent communication focus  |

### Detailed Breakdown

1. **Bumblebee** 🐝
   - **Core Function**: Execute pre-trained models (text, vision, speech)
   - **Key Features**:
     - ONNX runtime integration
     - Pre-built model architectures
     - Hardware acceleration support
   - **RAG Usage**: Critical for local LLM inference & embeddings

2. **Axon** 🤖
   - **Core Function**: Build/train custom neural networks
   - **Key Features**:
     - Differentiable programming
     - Model training pipelines
   - **RAG Usage**: Only needed if creating custom:
     - Embedding models
     - Fine-tuning adapters

3. **instructor_ex** 📋
   - **Core Function**: Structured LLM output validation
   - **Key Features**:
     - Ecto-compatible schemas
     - Response type enforcement
   - **RAG Usage**: Helpful for:
     - Parsing analysis results
     - API response standardization

4. **Jido** 自動
   - **Core Function**: Autonomous agent framework
   - **Key Features**:
     - Agent message routing
     - Long-term memory support
   - **RAG Usage**: Only relevant if building:
     - Self-initiating test agents
     - Multi-agent analysis systems

### Recommended Starting Point
```elixir:mix.exs
defp deps do
  [
    # Core RAG
    {:bumblebee, "~> 0.4"},
    
    # Optional enhancements
    {:instructor_ex, "~> 0.1", optional: true},
    {:axon, "~> 0.6", optional: true}
  ]
end
```