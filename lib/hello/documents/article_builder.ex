defmodule Hello.Documents.ArticleBuilder do
  alias Hello.Documents.Article
  alias Hello.Documents.Outline

  def generate_content(topic) do
    initial_messages = [
      %{role: :system, content: "You are an expert at crafting SEO friendly blog articles"}
    ]

    with {:outline, {:ok, _outline, outline_messages}} <-
           {:outline, create_outline(initial_messages, topic)},
         {:article, {:ok, article, _article_messages}} <-
           {:article, create_article(outline_messages)},
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

  def create_article(messages) do
    messages =
      messages ++
        [%{role: :user, content: "Please generate a full article based on the provided outline"}]

    run_query(messages, Article)
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
    config = Hello.LLM.Config.get()

    {:ok, response} =
      InstructorLite.instruct(
        %{messages: messages, model: config.chat_model},
        response_model: response_model,
        adapter_context: [
          api_key: config.api_key,
          url: config.chat_endpoint
        ],
        adapter: Hello.LLM.MyAdapter
      )

    {:ok, response,
     messages ++ [%{role: :assistant, content: response_model.represent(response)}]}
  end
end
