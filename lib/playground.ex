defmodule Playground do
  def chat() do
    Hello.LLM.ChatClient.chat(%{
      "messages" => [
        %{"content" => "what is the capital of France?", "role" => "user"}
      ],
      "model" => "#{Hello.LLM.Config.get().chat_model}",
      "temperature" => 1
    })
  end

  def chat_stream() do
    Hello.LLM.ChatClient.chat(
      %{
        "messages" => [
          %{"content" => "tell me a story in 10 words", "role" => "user"}
        ],
        "model" => "#{Hello.LLM.Config.get().chat_model}",
        "temperature" => 1
      },
      stream: fn x -> dbg(x) end
    )
  end

  def chat_api_curl() do
    # spawn a process to use curl to call out service
    # `curl -i 'http://localhost:4000/api/chat' -H "content-type: application/json" --data-raw '{"request":{"model":"gpt-3.5-turbo","temperature":1,"messages":[{"role":"user","content":"Hello 3.5!"}]}}'

    url = "http://localhost:4000/api/chat"
    headers = "-H"
    content_type = "content-type: application/json"
    data = ~s({
      "request": {
        "model": "#{Hello.LLM.Config.get().chat_model}",
        "temperature": 1,
        "messages": [
          {
            "role": "user",
            "content": "tell me a story in 10 words"
          }
        ]
      }
    })

    {output, status} =
      System.cmd("curl", [
        "-i",
        url,
        headers,
        content_type,
        "--data-raw",
        data
      ])

    IO.puts("Status: #{status}")
    IO.puts("Output:\n#{output}")
  end
end
