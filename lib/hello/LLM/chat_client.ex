defmodule Hello.LLM.ChatClient do
  @moduledoc """
  A client module for interacting with an LLM-compatible chat API.

  This module allows sending prompts to an LLM endpoint, supporting both standard
  (non-streaming) and streaming responses. It uses the `Req` library to perform HTTP
  requests and expects the configuration (e.g., endpoint, API key, model) to be provided
  by `Hello.LLM.Config`.

  ## Examples

      iex> Hello.LLM.ChatClient.chat("What is the capital of France?")
      {:ok, ["Paris"]}

      iex> Hello.LLM.ChatClient.chat("tell me a story in 10 words", stream: fn x -> dbg(x) end)
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

  def chat(request, opts \\ [stream: nil]) do
    request |> dbg()
    stream_callback = Keyword.get(opts, :stream, nil)

    body =
      request
      |> maybe_stream_body(stream_callback)

    case stream_callback do
      nil -> do_chat_normal(body)
      _ -> do_chat_stream(body, stream_callback)
    end
  end

  defp maybe_stream_body(body, nil), do: body

  defp maybe_stream_body(body, stream_callback) when is_function(stream_callback) do
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

  defp do_chat_stream(body, stream_callback) do
    Req.new(
      url: endpoint(),
      headers: headers(),
      json: body,
      into: fn {:data, data}, acc ->
        data |> parse() |> Enum.each(stream_callback)
        {:cont, acc}
      end
    )
    |> Req.post()
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
end
