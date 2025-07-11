defmodule Hello.Documents.LandingPageGenerator do
  # alias Hello.Documents.LandingPage.LandingPageSection
  alias Hello.Documents.LandingPage
  alias Hello.Documents.LandingPage.Feedback

  @max_iterations 4

  def run() do
    propose_landing_page("""
    Reynote.com is an AI powered relationship coach.
    It features full therapy sessions based on integrative therapy principles,
    a swarm of specialized AIs, journaling, progress tracking and more.

    What makes it unique is that it's meant to be used as a couple,
    where the AI has access to both perspectives and can serve as a bridge
    between, clearing misunderstandings and helping the relationship grow.
    """)
  end

  def propose_landing_page(project_info) do
    initial_chain = [
      %{
        role: :system,
        content:
          "You are an expert marketer, specializing in building landing pages that convert very well"
      },
      %{
        role: :user,
        content: "Please propose a landing page for the following project: #{project_info}"
      }
    ]

    {:ok, proposal, proposal_messages} = run_query(initial_chain, LandingPage)
    {:ok, feedback, _feedback_messages} = provide_feedback(proposal_messages)
    iterate_on_landing_page(project_info, proposal_messages, proposal, feedback, 0)
  end

  def iterate_on_landing_page(
        project_info,
        messages,
        _latest_proposal,
        %{needs_refinement: true} = feedback,
        iteration
      )
      when iteration < @max_iterations do
    # Add the feedback as a user message to guide refinement
    refinement_messages =
      messages ++
        [
          %{
            role: :user,
            content: """
            Based on this feedback, please improve the landing page structure:

            FEEDBACK:
            #{Enum.join(feedback.feedback, "\n")}

            Create an improved version that addresses these points.
            """
          }
        ]

    # Generate a refined proposal
    {:ok, refined_proposal, new_messages} = run_query(refinement_messages, LandingPage)

    # Get feedback on the refined proposal
    {:ok, new_feedback, _feedback_messages} = provide_feedback(new_messages)

    # Continue the iteration process with the refined proposal
    iterate_on_landing_page(
      project_info,
      new_messages,
      refined_proposal,
      new_feedback,
      iteration + 1
    )
  end

  # if no new refinement is necessary or we've reached  max iterations,
  # return the latest proposal
  def iterate_on_landing_page(
        _project_info,
        _messages,
        latest_proposal,
        _feedback,
        _iteration
      ) do
    latest_proposal
  end

  def provide_feedback(messages) do
    # In order to simplify things, we'll work on the original chain
    # but we will replace the system message and convert all assistant
    # messages to user messages
    messages =
      messages
      |> Enum.map(fn
        %{role: :system} ->
          %{
            role: :system,
            content:
              "You are an expert marketer, giving feedback on a proposed landing page plan, based on a project plan. Be pedantic, think of questions a visitor might have and make sure they're answered clearly."
          }

        %{role: :assistant, content: content} ->
          %{
            role: :user,
            content: "PROPOSED STRUCTURE: #{content}"
          }

        msg ->
          msg
      end)

    messages =
      messages ++
        [
          %{
            role: :user,
            content:
              "Provide detailed feedback on the proposed structure. Only say that it doesn't require refinement if you have 0 objections."
          }
        ]

    run_query(messages, Feedback)
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
