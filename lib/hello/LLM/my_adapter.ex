defmodule Hello.LLM.MyAdapter do
  @moduledoc """
  Use https://hexdocs.pm/instructor_lite/custom-ollama-adapter.html
  to write our own adapter
  You could use `InstructorLite.Adapters.OpenAI` as reference.
  """
  @behaviour InstructorLite.Adapter
  @default_model "gpt-4o-mini"

  @send_request_schema NimbleOptions.new!(
                         api_key: [
                           type: :string,
                           required: true,
                           doc: "OpenAI API key"
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
                           default: "https://api.openai.com/v1/responses",
                           doc: "API endpoint to use for sending requests"
                         ]
                       )

  @doc """
  Make request to OpenAI API.

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

  It uses `instructions` parameter for system prompt.

  Also specifies default `#{@default_model}` model if not provided by a user.
  """
  @impl InstructorLite.Adapter
  def initial_prompt(params, opts) do
    params
    |> Map.put_new(:model, @default_model)
    |> Map.put_new(:text, %{
      format: %{
        type: "json_schema",
        name: "schema",
        strict: true,
        schema: Keyword.fetch!(opts, :json_schema)
      }
    })
    |> Map.put_new(:instructions, InstructorLite.Prompt.prompt(opts))
  end

  @doc """
  Updates `params` with prompt for retrying a request.

  If the initial request was made with conversation state (enabled by
  default), it will drop previous chat messages from the request and specify
  `previous_response_id` instead. If conversation state is disabled, it will
  append new messages to the previous `input` the same way chat completions-based
  adapters do.
  """
  @impl InstructorLite.Adapter
  def retry_prompt(params, resp_params, errors, response, _opts) do
    do_better = [
      %{
        role: "system",
        content: InstructorLite.Prompt.validation_failed(errors)
      }
    ]

    case response do
      %{"store" => true, "id" => response_id} ->
        params
        |> Map.put(:input, do_better)
        |> Map.put(:previous_response_id, response_id)
        |> Map.delete(:instructions)

      _ ->
        Map.update!(params, :input, fn input ->
          assistant_response = %{
            role: "assistant",
            content: InstructorLite.JSON.encode!(resp_params)
          }

          if is_binary(input) do
            [%{role: "user", content: input}, assistant_response | do_better]
          else
            input ++ [assistant_response | do_better]
          end
        end)
    end
  end

  @impl InstructorLite.Adapter
  def parse_response(response, _opts) do
    case response do
      %{"choices" => [%{"message" => message}]} ->
        case message do
          %{"role" => "assistant", "refusal" => nil, "content" => content} ->
            InstructorLite.JSON.decode(content)

          %{"role" => "assistant", "refusal" => reason} ->
            {:error, :refusal, reason}
        end

      other ->
        {:error, :unexpected_response, other}
    end
  end
end

defmodule MyAdapterTest do
  @response %{
    "choices" => [
      %{
        "finish_reason" => "length",
        "index" => 0,
        "logprobs" => nil,
        "message" => %{
          "annotations" => [],
          "content" =>
            "Certainly! Here's a comprehensive SEO-friendly outline for an article on the topic: **\"Impact of AI on White Collar Jobs\"**.\n\n---\n\n### Article Title:  \n**The Impact of AI on White Collar Jobs: Opportunities, Challenges & the Future of Work**\n\n---\n\n### Meta Description:  \nDiscover how artificial intelligence is transforming white collar jobs across industries. Learn about its benefits, threats, and what the future holds for professionals in the age of AI.\n\n---\n\n### Outline:\n\n#### Introduction\n- Brief explanation of AI and its growing role in modern workplaces.\n- Overview of \"white collar jobs\" and their significance in today's economy.\n- Purpose of the article: to analyze how AI impacts white collar employment.\n\n---\n\n### Section 1: Understanding White Collar Jobs\n- Definition and examples of white collar jobs (e.g., finance, law, healthcare, marketing, administration).\n- Historical context: automation and its effect on labor.\n\n---\n\n### Section 2: Ways AI Is Transforming White Collar Roles\n- Automation of repetitive tasks (e.g., data entry, scheduling, reporting).\n- AI-powered decision-making tools and analytics.\n- Enhancing productivity and reducing human error.\n- Examples by industry:\n  - Finance: robo-advisors, fraud detection\n  - Legal: contract review, legal research\n  - Healthcare: diagnostic tools, medical imaging\n  - Marketing: customer segmentation, content generation\n\n---\n\n### Section 3: Benefits of AI for White Collar Workers\n- Increased efficiency and time savings\n- Opportunity to focus on higher-level creative and strategic tasks\n- Improved accuracy and insights for better decision-making\n- Potential for job augmentation rather than job elimination\n\n---\n\n### Section 4: Challenges and Concerns\n- Risk of job displacement and redundancy\n- Need for reskilling and upskilling\n- Ethical considerations (e.g., bias in algorithms, transparency)\n- Data privacy and security concerns\n\n---\n\n### Section 5: The Future of White Collar Work in the Age of AI\n- Emergence of new job roles and industries\n- The importance of human-AI collaboration\n- Predictions from industry experts and reports (e.g., McKinsey, PwC)\n- Preparing the workforce: education and policy implications\n\n---\n\n### Section 6: What Professionals Can Do to Adapt\n- Embrace lifelong learning and digital literacy\n- Build expertise in areas difficult to automate (e.g., emotional intelligence, leadership, creative thinking)\n- Leverage AI tools to enhance personal performance\n\n---\n\n### Conclusion\n- Recap of the key impacts of",
          "refusal" => nil,
          "role" => "assistant"
        }
      }
    ],
    "created" => 1_752_055_398,
    "id" => "chatcmpl-BrLvyknF0VEFpdBN0B2faOa8keF22",
    "model" => "chatgpt-4o-latest",
    "object" => "chat.completion",
    "system_fingerprint" => "fp_afccf7958a",
    "usage" => %{
      "completion_tokens" => 16128,
      "completion_tokens_details" => %{
        "accepted_prediction_tokens" => 0,
        "audio_tokens" => 0,
        "reasoning_tokens" => 0,
        "rejected_prediction_tokens" => 0
      },
      "prompt_tokens" => 410,
      "prompt_tokens_details" => %{"audio_tokens" => 0, "cached_tokens" => 0},
      "total_tokens" => 16538
    }
  }

  def parse_response() do
    @response |> Hello.LLM.MyAdapter.parse_response([])
  end
end
