defmodule HelloWeb.ChatLive.Index do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :messages, [])
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <div class="h-screen h-full w-full max-w-3xl flex flex-col mx-auto bg-gray-50 drop-shadow text-gray-700">
        <ol class="grow flex flex-col-reverse overflow-y-auto">
          <li :for={message <- @messages}>{message.content}</li>
          <li class="h-full hidden only:flex items-center justify-center">
            No messages. Enter a message below to begin.
          </li>
        </ol>
        <div class="shrink-0 w-full">
          <form phx-submit="submit" class="border-t border-gray-200 p-4 space-y-2">
            <textarea
              name="content"
              class="block resize-none w-full border-gray-200 rounded bg-white focus:ring-0 focus:border-gray-300 focus:shadow-sm"
              placeholder="Enter a message..."
              rows={4}
            ></textarea>
            <div class="flex justify-end">
              <button class="bg-gray-200 hover:bg-gray-300 transition px-3 py-1.5 rounded flex items-center justify-center">
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
    {:noreply, socket |> assign(:messages, updated_messages)}
  end
end
