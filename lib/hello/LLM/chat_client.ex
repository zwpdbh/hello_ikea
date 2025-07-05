defmodule Hello.LLM.ChatClient do
  @moduledoc """
  Provides functions to send chat prompts to an LLM-compatible API.

  ## Examples

      iex> Hello.LLM.ChatClient.chat("What is the capital of France?")
      {:ok, ["Paris"]}

      iex> Hello.LLM.ChatClient.chat("Tell me a story in 10 words", stream: true)
      :ok

  This module supports both streamed and non-streamed LLM responses.
  """
  require Logger

  def endpoint, do: Hello.LLM.Config.get().chat_endpoint
  def api_key, do: Hello.LLM.Config.get().api_key

  defp headers do
    [
      {"authorization", "Bearer #{api_key()}"},
      {"content-type", "application/json"},
      {"accept", "*/*"}
    ]
  end

  def chat(prompt, opts \\ [stream: false]) do
    stream? = Keyword.get(opts, :stream, false)

    body =
      %{
        "model" => Hello.LLM.Config.get().chat_model,
        "messages" => [
          %{
            "role" => "user",
            "content" => prompt,
            "name" => "text"
          }
        ]
      }
      |> maybe_stream_body(stream?)

    if stream? do
      do_chat_stream(body)
    else
      do_chat_normal(body)
    end
  end

  defp maybe_stream_body(body, false), do: body

  defp maybe_stream_body(body, true) do
    Map.merge(body, %{
      "stream" => true,
      "stream_options" => %{"include_usage" => true}
    })
  end

  defp do_chat_normal(body) do
    case Req.post(url: endpoint(), headers: headers(), json: body) do
      {:ok, %Req.Response{status: status, body: %{"choices" => choices}}}
      when status in [200, 201] ->
        {:ok, Enum.map(choices, fn c -> c["message"]["content"] end)}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Unexpected response #{status}: #{inspect(body)}"}

      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp do_chat_stream(body) do
    Req.new(
      url: endpoint(),
      headers: headers(),
      json: body,
      into: &process_stream/2
    )
    |> Req.post()
  end

  defp process_stream({:data, data}, acc) do
    data |> parse() |> Enum.each(&callback/1)
    {:cont, acc}
  end

  defp parse(chunk) do
    chunk
    |> String.split("data: ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&decode/1)
    |> Enum.reject(&is_nil/1)
  end

  defp decode(""), do: nil
  defp decode("[DONE]"), do: nil
  defp decode(data), do: Jason.decode!(data)

  def callback(x) do
    x |> dbg()
  end
end
