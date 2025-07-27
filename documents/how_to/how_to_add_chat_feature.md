# How to add chat feature 

Currently, we could use `req` to send api request to `OpenAI` and receive the response in chunk.
How to set up a chat feature? 
- As a service, our api endpoint need to supply a stream data just like `OpenAI`'s from controller.
- We need to setup liveview to make user could do chat like in `ChatGPT`.

We will explore two approches.
- One is implement this feature by following [Streaming OpenAI in Elixir Phoenix](https://benreinhart.com/blog/openai-streaming-elixir-phoenix/?utm_source=elixir-merge).
- Another is use `Ash` to support this json api. 

## Notes from implement features from `Streaming OpenAI in Elixir Phoenix`. 

Implemented a module and API endpoint for streaming out LLM completions. 

- Use `~s(...)` to wrap the json string, because we need to use double quote in the string.
- At this stage, `Playground.chat_api_curl` return something like 

```txt
Output:
HTTP/1.1 200 OK
transfer-encoding: chunked
date: Mon, 07 Jul 2025 07:40:26 GMT
vary: accept-encoding
cache-control: max-age=0, private, must-revalidate
x-request-id: GE_oJUMPuxVN-kIAAADE
content-type: application/x-ndjson; charset=utf-8

{"choices":[{"delta":{"content":"","refusal":null,"role":"assistant"},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":"Alien","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" bef","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":"riends","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" child","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":",","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" teaches","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" peace","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":",","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" van","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":"ishes","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" beneath","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" glowing","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":" moon","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"content":".","refusal":null},"finish_reason":null,"index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[{"delta":{"refusal":null},"finish_reason":"stop","index":0}],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":null}
{"choices":[],"created":1751874028,"id":"chatcmpl-BqakedFxwGdOkVEH6Xy95BNEvKnVj","model":"chatgpt-4o-latest","object":"chat.completion.chunk","system_fingerprint":"fp_afccf7958a","usage":{"completion_tokens":441,"completion_tokens_details":{"accepted_prediction_tokens":0,"audio_tokens":0,"reasoning_tokens":0,"rejected_prediction_tokens":0},"prompt_tokens":158,"prompt_tokens_details":{"audio_tokens":0,"cached_tokens":0},"total_tokens":599}}
```

## Notes from implement features from `Streaming OpenAI in Elixir Phoenix Part II`. 

Current status of parsing.

```elixir 
  defp parse(chunk) do
    chunk
    |> dbg()
    |> String.split("data: ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&decode/1)
    |> Enum.reject(&is_nil/1)
  end

  defp decode(""), do: nil
  defp decode("[DONE]"), do: nil
  defp decode(data), do: Jason.decode!(data)
```

It relys on the fact the each chunk must be zero or more complete events.

```sh
[(hello 0.1.0) lib/hello/LLM/chat_client.ex:84: Hello.LLMProvider.ChatClient.parse/1]
chunk #=> "data: {\"id\":\"chatcmpl-BqaxTMJAA7ZffdVrhjxaX1iDa3Sjz\",\"choices\":[{\"delta\":{\"content\":\"Dog\",\"refusal\":null},\"index\":0,\"finish_reason\":null}],\"created\":1751874823,\"model\":\"chatgpt-4o-latest\",\"object\":\"chat.completion.chunk\",\"usage\":null,\"system_fingerprint\":\"fp_afccf7958a\"}\n\ndata: {\"id\":\"chatcmpl-BqaxTMJAA7ZffdVrhjxaX1iDa3Sjz\",\"choices\":[{\"delta\":{\"content\":\" found\",\"refusal\":null},\"index\":0,\"finish_reason\":null}],\"created\":1751874823,\"model\":\"chatgpt-4o-latest\",\"object\":\"chat.completion.chunk\",\"usage\":null,\"system_fingerprint\":\"fp_afccf7958a\"}\n\n"

[(hello 0.1.0) lib/playground.ex:21: Playground.chat_stream/0]
x #=> %{
  "choices" => [
    %{
      "delta" => %{"content" => "Dog", "refusal" => nil},
      "finish_reason" => nil,
      "index" => 0
    }
  ],
  "created" => 1751874823,
  "id" => "chatcmpl-BqaxTMJAA7ZffdVrhjxaX1iDa3Sjz",
  "model" => "chatgpt-4o-latest",
  "object" => "chat.completion.chunk",
  "system_fingerprint" => "fp_afccf7958a",
  "usage" => nil
}
```

What if the bytes that comprise one or more of the events in the stream arrive at different times?
It means in a complete message is attrived in two events. Then the parsing will failed.

HTTP buffering -- Some server environments will buffer data and send the data to the client once the buffer reaches a certain size.
It’s possible there is a proxy (or some other middleman) that sits between the source server and the client. 
If this is the case, it’s possible that a client reading from a stream of events will 
receive portions of an event at a time and thus be responsible for stringing them back together.

Solution: introduce state into our parser.

- Step01, rework the parse to remove the assumption that an entire event is present at once. 
  - That this moment, when doing unit test, we could still test it with complete event.
  - It is just we added a buffer to the `parse` interface function to parse the chunk one character at a time. 

- Step02, the `buffer` introduced from `Step01` is constant and doesn't have state between the arrival of different chunks. 
  - So, we use `Agent` to update it between the arrival of different chunks. in `into` callback function of `Req.new`.

## References 
- [Getting started with AshJsonApi](https://hexdocs.pm/ash_json_api/1.4.36/getting-started-with-ash-json-api.html)
- [Streaming OpenAI in Elixir Phoenix](https://benreinhart.com/blog/openai-streaming-elixir-phoenix/?utm_source=elixir-merge)
- [Streaming OpenAI in Elixir Phoenix Part II](https://benreinhart.com/blog/openai-streaming-elixir-phoenix-part-2/)
  - [Learn parser: A robust and efficient decoder and encoder for the KDL Document Language in Elixir](https://github.com/benjreinhart/ex_kdl)
- [Streaming OpenAI in Elixir Phoenix Part III](https://benreinhart.com/blog/openai-streaming-elixir-phoenix-part-3/)
