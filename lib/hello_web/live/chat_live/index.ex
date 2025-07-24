# This is from example:
# Streaming OpenAI in Elixir Phoenix Part III -- https://benreinhart.com/blog/openai-streaming-elixir-phoenix-part-3/
defmodule HelloWeb.ChatLive.Index do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:messages, [])
      |> assign(:running, false)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <div class="h-screen h-full w-full max-w-3xl flex flex-col mx-auto bg-gray-50 drop-shadow text-gray-700">
        <ol class="grow flex flex-col-reverse overflow-y-auto">
          <li
            :for={message <- @messages}
            class="p-4 flex items-start space-x-4 border-b first:border-b-0 hover:bg-gray-200 transition-colors"
          >
            <div class="shrink-0 pt-0.5 opacity-75">
              <svg
                :if={message.role == :assistant}
                width="24"
                height="24"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M22.282 9.821a5.985 5.985 0 0 0-.516-4.91 6.046 6.046 0 0 0-6.51-2.9A6.065 6.065 0 0 0 4.981 4.18a5.985 5.985 0 0 0-3.998 2.9 6.046 6.046 0 0 0 .743 7.097 5.98 5.98 0 0 0 .51 4.911 6.051 6.051 0 0 0 6.515 2.9A5.985 5.985 0 0 0 13.26 24a6.056 6.056 0 0 0 5.772-4.206 5.99 5.99 0 0 0 3.997-2.9 6.056 6.056 0 0 0-.747-7.073zM13.26 22.43a4.476 4.476 0 0 1-2.876-1.04l.141-.081 4.779-2.758a.795.795 0 0 0 .392-.681v-6.737l2.02 1.168a.071.071 0 0 1 .038.052v5.583a4.504 4.504 0 0 1-4.494 4.494zM3.6 18.304a4.47 4.47 0 0 1-.535-3.014l.142.085 4.783 2.759a.771.771 0 0 0 .78 0l5.843-3.369v2.332a.08.08 0 0 1-.033.062L9.74 19.95a4.5 4.5 0 0 1-6.14-1.646zM2.34 7.896a4.485 4.485 0 0 1 2.366-1.973V11.6a.766.766 0 0 0 .388.676l5.815 3.355-2.02 1.168a.076.076 0 0 1-.071 0l-4.83-2.786A4.504 4.504 0 0 1 2.34 7.872zm16.597 3.855l-5.833-3.387L15.119 7.2a.076.076 0 0 1 .071 0l4.83 2.791a4.494 4.494 0 0 1-.676 8.105v-5.678a.79.79 0 0 0-.407-.667zm2.01-3.023l-.141-.085-4.774-2.782a.776.776 0 0 0-.785 0L9.409 9.23V6.897a.066.066 0 0 1 .028-.061l4.83-2.787a4.5 4.5 0 0 1 6.68 4.66zm-12.64 4.135l-2.02-1.164a.08.08 0 0 1-.038-.057V6.075a4.5 4.5 0 0 1 7.375-3.453l-.142.08L8.704 5.46a.795.795 0 0 0-.393.681zm1.097-2.365l2.602-1.5 2.607 1.5v2.999l-2.597 1.5-2.607-1.5z"
                  fill="currentColor"
                />
              </svg>
              <svg
                :if={message.role == :user}
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z" />
              </svg>
            </div>
            <div class="leading-7 whitespace-pre-wrap">{message.content}</div>
          </li>
          <li class="h-full hidden only:flex items-center justify-center">
            No messages. Enter a message below to begin.
          </li>
        </ol>
        <div class="shrink-0 w-full">
          <form phx-submit="submit" class="border-t border-gray-200 p-4 space-y-2">
            <textarea
              id="content"
              phx-hook="SubmitOnCmdEnter"
              name="content"
              class="block resize-none w-full border-gray-200 rounded bg-white focus:ring-0 focus:border-gray-300 focus:shadow-sm"
              placeholder="Enter a message..."
              rows={4}
            ></textarea>
            <div class="flex justify-end">
              <button
                disabled={@running}
                class="bg-gray-200 hover:bg-gray-300 transition px-3 py-1.5 rounded flex items-center justify-center"
              >
                Send
              </button>
            </div>
          </form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("submit", %{"content" => content}, socket) do
    message = %{role: :user, content: content}
    updated_messages = [message | socket.assigns.messages]

    pid = self()

    socket =
      socket
      |> assign(:messages, updated_messages)
      |> assign(:running, true)
      |> start_async(:chat_completion, fn ->
        run_chat_completion(pid, Enum.reverse(updated_messages))
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:chunk, chunk}, socket) do
    updated_messages =
      case socket.assigns.messages do
        [%{role: :assistant, content: content} | messages] ->
          [%{role: :assistant, content: content <> chunk} | messages]

        messages ->
          [%{role: :assistant, content: chunk} | messages]
      end

    {:noreply, assign(socket, :messages, updated_messages)}
  end

  @impl true
  def handle_async(:chat_completion, _result, socket) do
    {:noreply, assign(socket, :running, false)}
  end

  defp run_chat_completion(pid, messages) do
    request = %{
      model: "#{Hello.LLMProvider.Config.get().chat_model}",
      temperature: 1,
      messages: messages
    }

    Hello.LLMProvider.ChatClient.chat(request,
      stream: fn chunk ->
        case chunk do
          %{"choices" => [%{"delta" => %{"content" => content}}]} ->
            send(pid, {:chunk, content})

          _ ->
            nil
        end
      end
    )
  end
end
