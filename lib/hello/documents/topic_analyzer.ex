defmodule Hello.Documents.TopicAnalyzer do
  @moduledoc """
  Demo Workflow 2: Routing
  1. We'll give a topic with some context about an article we want to produce
  2. A router will classify the topic into predefined categories, along with relevant search terms
  3. A custom search tool will perform a query (we'll be mocking this)
  4. A specific LLM prompt will be invoked per-category, generating a summary and key points.
  """
  alias Hello.Documents.Summary
  alias Hello.Documents.TopicClassification

  def analyze_topic(topic) do
    initial_messages = [
      %{role: :system, content: "You are an expert at classifying topics into domains."}
    ]

    with {:classify, {:ok, classification, _classification_messages}} <-
           {:classify, classify_topic(initial_messages, topic)},
         {:search, {:ok, search_data}} <-
           {:search, search_by_domain(classification)},
         {:summarize, {:ok, summary, _content}} <-
           {:summarize, create_summary(classification, search_data)} do
      {:ok, summary}
    end
  end

  defp classify_topic(messages, topic) do
    messages =
      messages ++
        [
          %{
            role: :user,
            content: "Classify this topic and provide specific search terms: #{topic}"
          }
        ]

    run_query(messages, TopicClassification)
  end

  defp search_by_domain(%TopicClassification{domain: :finance, search_terms: _terms}) do
    # Mock Yahoo Finance data
    {:ok,
     %{
       "stock_price" => "$156.42",
       "daily_change" => "+2.3%",
       "trading_volume" => "12.3M",
       "recent_news" => [
         "Company announces new product line",
         "Q3 earnings beat expectations"
       ]
     }}
  end

  defp search_by_domain(%TopicClassification{domain: :science, search_terms: terms}) do
    # Mock arXiv data
    {:ok,
     %{
       "papers" => [
         %{
           "title" => "Recent Advances in #{terms}",
           "abstract" => "This paper explores...",
           "citations" => 42
         },
         %{
           "title" => "Novel Approaches to #{terms}",
           "abstract" => "We present...",
           "citations" => 17
         }
       ]
     }}
  end

  defp search_by_domain(%TopicClassification{domain: :entertainment, search_terms: terms}) do
    # Mock Twitter data
    {:ok,
     %{
       "tweets" => [
         %{
           "text" => "Can't believe the latest news about #{terms}! #trending",
           "likes" => 1234
         },
         %{
           "text" => "#{terms} just changed the game forever",
           "likes" => 5678
         }
       ],
       "sentiment" => "mostly positive"
     }}
  end

  defp create_summary(classification, search_data) do
    messages = [
      %{
        role: :system,
        content: get_domain_prompt(classification.domain)
      },
      %{
        role: :user,
        content: """
        Create a summary of this #{classification.domain} data about #{classification.search_terms}:

        #{Jason.encode!(search_data, pretty: true)}
        """
      }
    ]

    run_query(messages, Summary)
  end

  defp get_domain_prompt(:finance) do
    """
    You are a financial analyst. Create a market summary focusing on:
    - Price movements and their significance
    - Trading patterns
    - News impact on the market
    - Future outlook
    """
  end

  defp get_domain_prompt(:science) do
    """
    You are a scientific researcher. Create a research summary focusing on:
    - Key findings from papers
    - Research trends
    - Significance of citations
    - Future research directions
    """
  end

  defp get_domain_prompt(:entertainment) do
    """
    You are an entertainment analyst. Create a trend summary focusing on:
    - Social media reaction
    - Public sentiment
    - Trending opinions
    - Cultural impact
    """
  end

  defp run_query(messages, response_model) do
    config = Hello.LLMProvider.Config.get()

    case InstructorLite.instruct(
           %{messages: messages},
           response_model: response_model,
           adapter: Hello.LLMProvider.MyAdapter,
           adapter_context: [
             api_key: config.api_key,
             url: config.chat_endpoint
           ]
         ) do
      {:ok, response} ->
        {:ok, response, messages ++ [%{role: :assistant, content: inspect(response)}]}

      error ->
        error
    end
  end
end
