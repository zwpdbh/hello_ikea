defmodule HelloWeb.BumblebeeLive.Index do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:text, nil)
      |> assign(:task, nil)
      |> assign(:result, nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <div class="h-screen m-auto flex items-center justify-center antialiased">
        <div class="flex flex-col h-1/2 w-1/2">
          <div>bumblebee prediction demo</div>
          <form class="m-0 flex space-x-2" phx-change="predict">
            <input
              class="block w-full p-2.5 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg"
              type="text"
              name="text"
              phx-debounce="300"
              value={@text}
            />
          </form>
          <div class="mt-2 flex space-x-1.5 items-center text-gray-600 text-lg">
            <span>Emotion:</span>
            <span class="text-gray-900 font-medium">{@result}</span>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
