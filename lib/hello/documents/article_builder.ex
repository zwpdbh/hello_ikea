defmodule Hello.Documents.ArticleBuilder do
  @moduledoc """
  Demo Workflow 1: Prompt chaining
  1. Given context generate outline
  2. Use outline generate article
  3. Translate the article into spanish
  """
  alias Hello.Documents.Article
  alias Hello.Documents.Outline

  # For example:
  # Hello.Documents.ArticleBuilder.generate_content("Impact of AI on white collar jobs")
  def generate_content(topic) do
    initial_messages = [
      %{role: :system, content: "You are an expert at crafting SEO friendly blog articles"}
    ]

    with {:outline, {:ok, outline, outline_messages}} <-
           {:outline, create_outline(initial_messages, topic)},
         {:article, {:ok, article, _article_messages}} <-
           {:article, create_article(outline_messages, outline)},
         {:translation, {:ok, translated_article, _translated_messages}} <-
           {:translation, translate_to(article, "german")} do
      {article, translated_article}
    else
      {stage, {:error, _err}} -> "Error in stage #{stage}"
    end
  end

  def create_outline(messages, topic) do
    messages =
      messages ++
        [
          %{
            role: :user,
            content: "Please generate an outline of an article about the following topic #{topic}"
          }
        ]

    run_query(messages, Outline)
  end

  # Currently there is a problem:
  # Article body gets generated, but then fails
  # because the response JSON is too long, so it is malformed
  def create_article_v1(messages, _outline) do
    messages =
      messages ++
        [%{role: :user, content: "Please generate a full article based on the provided outline"}]

    run_query(messages, Article)
  end

  def create_article(messages, %Outline{outline: sections}) do
    article_sections =
      Enum.map(sections, fn section ->
        article_messages =
          messages ++ [%{role: :user, content: "Write the section: #{section}"}]

        {:ok, %Article{response: content}, _} = run_query(article_messages, Article)
        "## #{section}\n\n#{content}"
      end)

    full_article = Enum.join(article_sections, "\n\n")
    {:ok, %Article{response: full_article}, messages}
  end

  def translate_to(%Article{response: content}, language \\ "spanish") do
    messages = [
      %{
        role: :system,
        content:
          "You are an expert polyglot translator, that provides article translations. Do not make any changes to the content other than translating it"
      },
      %{
        role: :user,
        content: "Please translate the following article into #{language}:\n\n#{content}"
      }
    ]

    run_query(messages, Article)
  end

  defp run_query(messages, response_model) do
    config = Hello.LLMProvider.Config.get()

    {:ok, response} =
      InstructorLite.instruct(
        %{messages: messages, model: config.chat_model},
        response_model: response_model,
        adapter: Hello.LLMProvider.MyAdapter,
        adapter_context: [
          api_key: config.api_key,
          url: config.chat_endpoint
        ]
      )

    {:ok, response,
     messages ++ [%{role: :assistant, content: response_model.represent(response)}]}
  end
end
