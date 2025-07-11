defmodule Hello.Documents.EssayTopicAnalysis do
  alias Hello.Documents.PerspectiveList
  alias Hello.Documents.PerspectiveList.ArrayResponse
  alias Hello.Documents.PerspectiveList.EssayOutline
  alias Hello.Documents.PerspectiveList.Runner

  def run() do
    run_analysis("Universal Basic Income: A Necessary Evolution of Social Welfare")
  end

  def run_analysis(topic) do
    # Generate a list of 3-5 perspectives
    {:ok, perspectives, _perspectives_messages} = get_perspectives(topic)

    # For each perspective create an async task (which in turn will create several more)
    analyses =
      perspectives.perspectives
      |> Enum.map(fn perspective ->
        # we're creating a callback function with a closure for each perspective
        fn -> provide_perspective_analysis(topic, perspective) end
      end)
      |> Runner.parallel()

    # Generate the final outline with all the collected analyses
    outline = generate_outline(topic, analyses)

    # Return both the detailed analyses and the synthesized outline
    %{
      analyses: analyses,
      outline: outline
    }
  end

  def get_perspectives(topic) do
    messages = [
      %{
        role: :user,
        content:
          "I'm writing an essay about: #{topic}. Suggest 3-5 perspectives through which to analyze it"
      }
    ]

    run_query(messages, PerspectiveList)
  end

  def provide_perspective_analysis(topic, perspective) do
    [{:ok, supportive, _}, {:ok, counter, _}, {:ok, biases, _}] =
      Runner.parallel([
        fn -> generate_supportive_arguments(topic, perspective) end,
        fn -> generate_counter_arguments(topic, perspective) end,
        fn -> analyze_biases(topic, perspective) end
      ])

    # NOTE: I didn't want to mock search results again, as it would just take
    # up space in the already long demo. You can imagine, as in the previous
    # example, the initial perspective generator could generate search terms
    # to use with something like https://exa.ai

    {perspective, {supportive, counter, biases}}
  end

  def generate_outline(topic, analyses) do
    # Format the analyses into a structured format for the LLM
    formatted_analyses =
      analyses
      |> Enum.map(fn {perspective, {supportive, counter, biases}} ->
        """
        ## #{perspective} Perspective:

        ### Supportive Arguments:
        #{format_points(supportive.response)}

        ### Counter Arguments:
        #{format_points(counter.response)}

        ### Potential Biases:
        #{format_points(biases.response)}
        """
      end)
      |> Enum.join("\n\n")

    messages = [
      %{
        role: :system,
        content:
          "You are an expert essay outline creator who can synthesize multiple perspectives into a coherent structure."
      },
      %{
        role: :user,
        content: """
        I'm writing an essay on the topic: "#{topic}"

        I've analyzed this topic from multiple perspectives.
        Here are the detailed analyses:

        #{formatted_analyses}

        Based on these analyses, please create:
        1. A comprehensive essay outline with main sections and subsections
        2. Brief notes for each section highlighting key points to address
        3. Suggestions for a balanced approach that considers multiple perspectives
        """
      }
    ]

    {:ok, outline, _} = run_query(messages, EssayOutline)
    outline
  end

  defp format_points(points) do
    points
    |> Enum.map(fn point -> "- #{point}" end)
    |> Enum.join("\n")
  end

  def generate_supportive_arguments(topic, perspective) do
    messages = [
      %{
        role: :user,
        content:
          "I'm writing an essay about: #{topic}. Suggest 3-5 points that are supportive or in favor, from the #{perspective} perspective"
      }
    ]

    run_query(messages, ArrayResponse)
  end

  def generate_counter_arguments(topic, perspective) do
    messages = [
      %{
        role: :user,
        content:
          "I'm writing an essay about: #{topic}. Suggest 3-5 points that are negative or in counter, from the #{perspective} perspective"
      }
    ]

    run_query(messages, ArrayResponse)
  end

  def analyze_biases(topic, perspective) do
    messages = [
      %{
        role: :user,
        content:
          "I'm writing an essay about: #{topic}. Suggest 3-5 biases in my topic or premise, from the #{perspective} perspective"
      }
    ]

    run_query(messages, ArrayResponse)
  end

  defp run_query(messages, response_model) do
    case InstructorLite.instruct(
           %{messages: messages},
           response_model: response_model,
           adapter_context: [api_key: System.get_env("OPENAI_API_KEY")]
         ) do
      {:ok, response} ->
        {:ok, response, messages ++ [%{role: :assistant, content: inspect(response)}]}

      error ->
        error
    end
  end
end
