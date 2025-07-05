defmodule Playground do
  def chat(prompt) do
    Hello.LLM.ChatClient.chat(prompt, stream: true)
  end
end
