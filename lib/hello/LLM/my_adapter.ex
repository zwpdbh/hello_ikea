defmodule Hello.LLM.MyAdapter do
  @moduledoc """
  Adapter for Chat Completions-compatible API endpoints, such as [OpenAI](https://platform.openai.com/docs/api-reference/chat) or [Grok](https://docs.x.ai/docs/api-reference#chat-completions).

  This adapter uses [structured outputs](https://platform.openai.com/docs/guides/structured-outputs/structured-outputs).

  ## Params
  `params` argument should be shaped as a [Create chat completion request body](https://platform.openai.com/docs/api-reference/chat/create).

  ## Example

  ```
  InstructorLite.instruct(%{
      messages: [%{role: "user", content: "John is 25yo"}],
      model: "gpt-4o-mini",
      service_tier: "default"
    },
    response_model: %{name: :string, age: :integer},
    adapter: InstructorLite.Adapters.ChatCompletionsCompatible,
    adapter_context: [
      api_key: Application.fetch_env!(:instructor_lite, :openai_key),
      url: "https://api.openai.com/v1/chat/completions"
    ]
  )
  {:ok, %{name: "John", age: 25}}
  ```
  """
  @behaviour InstructorLite.Adapter

  @default_model "gpt-4o-mini"

  @send_request_schema NimbleOptions.new!(
                         api_key: [
                           type: :string,
                           required: true,
                           doc: "API key"
                         ],
                         http_client: [
                           type: :atom,
                           default: Req,
                           doc: "Any module that follows `Req.post/2` interface"
                         ],
                         http_options: [
                           type: :keyword_list,
                           default: [receive_timeout: 60_000],
                           doc: "Options passed to `http_client.post/2`"
                         ],
                         url: [
                           type: :string,
                           default: "https://api.openai.com/v1/chat/completions",
                           doc: "API endpoint to use for sending requests"
                         ]
                       )

  @doc """
  Make request to API.

  ## Options

  #{NimbleOptions.docs(@send_request_schema)}
  """
  @impl InstructorLite.Adapter
  def send_request(params, opts) do
    context =
      opts
      |> Keyword.get(:adapter_context, [])
      |> NimbleOptions.validate!(@send_request_schema)

    options =
      Keyword.merge(context[:http_options], json: params, auth: {:bearer, context[:api_key]})

    case context[:http_client].post(context[:url], options) do
      {:ok, %{status: status_code, body: body}} when status_code in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Updates `params` with prompt based on `json_schema` and `notes`.

  Also specifies default `#{@default_model}` model if not provided by a user.
  """
  @impl InstructorLite.Adapter
  def initial_prompt(params, opts) do
    sys_message = [
      %{
        role: "system",
        content: InstructorLite.Prompt.prompt(opts)
      }
    ]

    params
    |> Map.put_new(:model, @default_model)
    |> Map.put_new(:response_format, %{
      type: "json_schema",
      json_schema: %{
        name: "schema",
        strict: true,
        schema: Keyword.fetch!(opts, :json_schema)
      }
    })
    |> Map.update(:messages, sys_message, fn msgs -> sys_message ++ msgs end)
  end

  @doc """
  Updates `params` with prompt for retrying a request.
  """
  @impl InstructorLite.Adapter
  def retry_prompt(params, resp_params, errors, _response, _opts) do
    do_better = [
      %{role: "assistant", content: InstructorLite.JSON.encode!(resp_params)},
      %{
        role: "system",
        content: InstructorLite.Prompt.validation_failed(errors)
      }
    ]

    Map.update(params, :messages, do_better, fn msgs -> msgs ++ do_better end)
  end

  @doc """
  Parse chat completion endpoint response.

  Can return:
    * `{:ok, parsed_json}` on success.
    * `{:error, :refusal, reason}` on [refusal](https://platform.openai.com/docs/guides/structured-outputs/refusals).
    * `{:error, :unexpected_response, response}` if response is of unexpected shape.
  """
  @impl InstructorLite.Adapter
  def parse_response(response, _opts) do
    # response |> dbg()

    case response do
      %{"choices" => [%{"message" => %{"content" => json, "refusal" => nil}}]} ->
        json |> dbg()

        InstructorLite.JSON.decode(json) |> dbg()

      %{"choices" => [%{"message" => %{"refusal" => refusal}}]} ->
        {:error, :refusal, refusal}

      other ->
        {:error, :unexpected_response, other}
    end
  end
end

defmodule MyAdapterTest do
  def case01() do
    %{
      "choices" => [
        %{
          "finish_reason" => "stop",
          "index" => 0,
          "logprobs" => nil,
          "message" => %{
            "annotations" => [],
            "content" =>
              "{\"outline\":[\"Introduction to Sci-Fi as a Genre\",\"Elements of a Simple Sci-Fi Story\",\"Creating Your Sci-Fi Characters\",\"Setting the Scene: Futuristic Worlds\",\"Developing a Basic Plot Structure\",\"Incorporating Sci-Fi Concepts: Technology and Alien Life\",\"Writing Dialogue for Sci-Fi Characters\",\"Crafting the Conflict: Man vs. Nature, Man vs. Self, or Man vs. Society\",\"Concluding Your Story: Resolutions and Lessons Learned\",\"Editing and Revising Your Sci-Fi Story\",\"Publishing and Sharing Your Sci-Fi Story\"]}",
            "refusal" => nil,
            "role" => "assistant"
          }
        }
      ],
      "created" => 1_752_122_186,
      "id" => "chatcmpl-BrdJClsKvFzZ9BrRpgG4up4vVwYPr",
      "model" => "gpt-4o-mini-2024-07-18",
      "object" => "chat.completion",
      "system_fingerprint" => "fp_34a54ae93c",
      "usage" => %{
        "completion_tokens" => 137,
        "completion_tokens_details" => %{
          "accepted_prediction_tokens" => 0,
          "audio_tokens" => 0,
          "reasoning_tokens" => 0,
          "rejected_prediction_tokens" => 0
        },
        "prompt_tokens" => 46,
        "prompt_tokens_details" => %{"audio_tokens" => 0, "cached_tokens" => 0},
        "total_tokens" => 183
      }
    }
    |> Hello.LLM.MyAdapter.parse_response([])
  end

  def case02() do
    %{
      "choices" => [
        %{
          "finish_reason" => "length",
          "index" => 0,
          "logprobs" => nil,
          "message" => %{
            "annotations" => [],
            "content" =>
              "{\"response\":\"# Write a Simple Sci-Fi Story: A Beginner's Guide\\n\\nSci-fi, short for science fiction, is a genre that opens the door to limitless possibilities. It allows writers to explore futuristic technologies, alien civilizations, and profound philosophical questions—often shedding light on contemporary social issues through imaginative storytelling. If you’re eager to pen your very own simple sci-fi story, this guide will walk you through the essential elements and provide tips to get your creative juices flowing.\\n\\n## Introduction to Sci-Fi as a Genre\\n\\nThe sci-fi genre is diverse, ranging from space operas to dystopian futures, and even speculative fiction that explores the implications of scientific advances. Understanding the wide range of sub-genres within sci-fi can inspire you to choose a thematic setting or premise that captivates your audience. Whether you're imagining life on Mars or a world governed by AI, remember that at its core, sci-fi is about exploring the unknown.\\n\\n## Elements of a Simple Sci-Fi Story\\n\\nA compelling sci-fi story generally includes several key elements:\\n- **Characters:** Well-developed characters who drive the narrative.\\n- **Setting:** A unique environment that enhances the story's premise.\\n- **Plot:** A clear and engaging storyline with a conflict that needs resolution.\\n- **Themes:** Underlying messages or questions that provoke thought.\\n\\nBy keeping these elements in mind, your story will achieve the depth and intrigue expected from a good sci-fi narrative.\\n\\n## Creating Your Sci-Fi Characters\\n\\nCharacters are the heart of any story. In sci-fi, your characters might be humans, aliens, robots, or any combination thereof. Create characters that are relatable yet complex. Think about their:\\n- Goals\\n- Motivations\\n- Backgrounds\\n- Relationships with other characters\\nEach character should serve a purpose in your narrative and contribute to the overall conflict and resolution.\\n\\n## Setting the Scene: Futuristic Worlds\\n\\nOne of the most exciting aspects of writing sci-fi is creating immersive and believable settings. Consider:\\n- **World-building:** What does your universe look like? What rules govern it?  \\n- **Technology:** How does advanced technology influence everyday life?  \\n- **Society:** What are the cultural norms and conflicts?\\nTake the time to develop your setting, as it will ground your characters and plot in a believable context.\\n\\n## Developing a Basic Plot Structure\\n\\nA simple plot structure often consists of three main parts:\\n1. **Introduction:**",
            "refusal" => nil,
            "role" => "assistant"
          }
        }
      ],
      "created" => 1_752_122_189,
      "id" => "chatcmpl-BrdJFOlfabnf7KXEQ5pgNUUAvjKP9",
      "model" => "gpt-4o-mini-2024-07-18",
      "object" => "chat.completion",
      "system_fingerprint" => "fp_62a23a81ef",
      "usage" => %{
        "completion_tokens" => 645,
        "completion_tokens_details" => %{
          "accepted_prediction_tokens" => 0,
          "audio_tokens" => 0,
          "reasoning_tokens" => 0,
          "rejected_prediction_tokens" => 0
        },
        "prompt_tokens" => 83,
        "prompt_tokens_details" => %{"audio_tokens" => 0, "cached_tokens" => 0},
        "total_tokens" => 728
      }
    }
    |> Hello.LLM.MyAdapter.parse_response([])
  end
end
