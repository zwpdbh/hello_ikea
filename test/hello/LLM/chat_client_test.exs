defmodule Hello.LLMProvider.ChatClientTest do
  use Hello.DataCase

  alias Hello.LLMProvider.ChatClient

  test "can parse complete chunks" do
    event_one = %{
      "choices" => [
        %{
          "delta" => %{"content" => "Hello"},
          "finish_reason" => nil,
          "index" => 0,
          "logprobs" => nil
        }
      ],
      "created" => 1_704_745_461,
      "id" => "chatcmpl-8eqSTjwUmipuvL2s8CzjmXd1dTS08",
      "model" => "gpt-3.5-turbo-0613",
      "object" => "chat.completion.chunk",
      "system_fingerprint" => nil
    }

    event_two = %{
      "choices" => [
        %{"delta" => %{"content" => "!"}, "finish_reason" => nil, "index" => 0, "logprobs" => nil}
      ],
      "created" => 1_704_745_461,
      "id" => "chatcmpl-8eqSTjwUmipuvL2s8CzjmXd1dTS08",
      "model" => "gpt-3.5-turbo-0613",
      "object" => "chat.completion.chunk",
      "system_fingerprint" => nil
    }

    chunk = """
    data: #{Jason.encode!(event_one)}

    data: #{Jason.encode!(event_two)}

    data: [DONE]

    """

    assert {[], [^event_one, ^event_two]} = ChatClient.parsev2([], chunk)
  end

  test "can parse incomplete chunks" do
    chunk_one =
      """
      data: {"id":"chatcmpl-8eqSTjwUmipuvL2s8CzjmXd1dTS08","object":"chat.completion.chunk","created":1704745
      """
      |> String.trim()

    chunk_two = """
    461,"model":"gpt-3.5-turbo-0613","system_fingerprint":null,"choices":[{"index":0,"delta":{"content":"Hello"},"logprobs":null,"finish_reason":null}]}

    """

    expected_event = %{
      "choices" => [
        %{
          "delta" => %{"content" => "Hello"},
          "finish_reason" => nil,
          "index" => 0,
          "logprobs" => nil
        }
      ],
      "created" => 1_704_745_461,
      "id" => "chatcmpl-8eqSTjwUmipuvL2s8CzjmXd1dTS08",
      "model" => "gpt-3.5-turbo-0613",
      "object" => "chat.completion.chunk",
      "system_fingerprint" => nil
    }

    assert {buffer, []} = ChatClient.parsev2([], chunk_one)
    assert {[], [^expected_event]} = ChatClient.parsev2(buffer, chunk_two)
  end
end
