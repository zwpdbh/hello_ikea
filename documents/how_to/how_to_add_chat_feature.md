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


## References 
- [Getting started with AshJsonApi](https://hexdocs.pm/ash_json_api/1.4.36/getting-started-with-ash-json-api.html)
- [Streaming OpenAI in Elixir Phoenix](https://benreinhart.com/blog/openai-streaming-elixir-phoenix/?utm_source=elixir-merge)
- [Streaming OpenAI in Elixir Phoenix Part II](https://benreinhart.com/blog/openai-streaming-elixir-phoenix-part-2/)
