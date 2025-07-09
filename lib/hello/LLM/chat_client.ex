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
    # Initialize buffer state
    {:ok, agent} = Agent.start_link(fn -> [] end)

    Req.new(
      url: endpoint(),
      headers: headers(),
      json: body,
      into: fn {:data, data}, acc ->
        # v1
        # data |> parse() |> Enum.each(stream_callback)

        # v2.a
        # {_buffer, events} = parsev2([], data)
        # Enum.each(events, stream_callback)

        # v2.b The agent preserves the buffer between the arrival of different chunks.
        buffer = Agent.get(agent, & &1)
        {buffer, events} = parsev2(buffer, data)
        Enum.each(events, stream_callback)

        # update buffer value with the result from calling parse/2
        :ok = Agent.update(agent, fn _ -> buffer end)

        {:cont, acc}
      end
    )
    |> Req.post()
  end

  # defp parse(chunk) do
  #   chunk
  #   |> dbg()
  #   |> String.split("data: ")
  #   |> Enum.map(&String.trim/1)
  #   |> Enum.map(&decode/1)
  #   |> Enum.reject(&is_nil/1)
  # end

  # defp decode(""), do: nil
  # defp decode("[DONE]"), do: nil
  # defp decode(data), do: Jason.decode!(data)

  # Different from v1 such that it use buffer as state to track the current event
  # and only emit the event when the event is complete.
  def parsev2(buffer, chunk) do
    parsev2(buffer, chunk, [])
  end

  # This clause matches when the buffer ends with a newline
  # and the chunk starts with a newline.
  defp parsev2([buffer | "\n"], "\n" <> rest, events) do
    case IO.iodata_to_binary(buffer) do
      "data: [DONE]" ->
        parsev2([], rest, events)

      "data: " <> event ->
        parsev2([], rest, [Jason.decode!(event) | events])
    end
  end

  # This function is used to eat the chunk one char at a time.
  defp parsev2(buffer, <<char::utf8, rest::binary>>, events) do
    parsev2([buffer | <<char::utf8>>], rest, events)
  end

  # When there is no more chunk, return the reversed events
  defp parsev2(buffer, "", events) do
    {buffer, Enum.reverse(events)}
  end
end
