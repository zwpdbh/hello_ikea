defmodule Playground do
  def chat() do
    Hello.LLM.ChatClient.chat("What is the capital of France?", stream: false)
  end

  def chat_stream() do
    Hello.LLM.ChatClient.chat("tell me a story in 10 words", stream: fn x -> dbg(x) end)
  end
end
