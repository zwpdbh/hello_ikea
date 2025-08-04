defmodule HelloWeb.TailwindLive.Demo06 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:sidebar_open, true)
      |> assign(:messages, [
        # %{from: "bot", content: "this is cool"},
        # %{from: "user01", content: "I am noob"},
        # %{from: "user02", content: "It is fine"}
      ])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen bg-white flex">
      <!-- Sidebar -->
      <div class={
          "transition-all duration-300 flex flex-col p-2 space-y-2 bg-gray-100 " <>
          if(@sidebar_open, do: "w-64", else: "w-16 overflow-hidden")
        }>
        <!-- Toggle Button -->
        <div class="flex justify-end">
          <button phx-click="toggle_sidebar" class="p-1 hover:bg-gray-400 rounded">
            <.icon
              name={
                if(@sidebar_open,
                  do: "hero-arrow-left-end-on-rectangle",
                  else: "hero-arrow-right-end-on-rectangle"
                )
              }
              class="w-6 h-6"
            />
          </button>
        </div>
        
    <!-- Sidebar Content (only visible when open) -->
        <div :if={@sidebar_open} class="space-y-1">
          <div class="flex items-center gap-1 hover:bg-gray-200 p-1 rounded">
            <.icon name="hero-pencil-square" />
            <span>new chat</span>
          </div>
          <div class="flex items-center gap-1 hover:bg-gray-200 p-1 rounded">
            <.icon name="hero-magnifying-glass" />
            <span>search</span>
          </div>
          <div class="text-gray-400 font-bold mt-2 text-sm">
            History
          </div>
          <div class="hover:bg-gray-200 p-1 rounded">chat history 01</div>
          <div class="hover:bg-gray-200 p-1 rounded">chat history 02</div>
          <div class="hover:bg-gray-200 p-1 rounded">chat history 03</div>
        </div>
      </div>

      <div class="flex-1 bg-gray-50 overflow-hidden flex flex-col">
        <div class="p-4 flex-1 flex flex-col">
          <div class={
            if @messages == [],
              do: "flex-1 flex items-center justify-center",
              else: "flex-col"
          }>
            <%= if @messages != [] do %>
              <div class="flex-1 overflow-y-auto bg-blue-200 rounded-lg p-2 mb-4">
                <.render_messages messages={@messages} />
              </div>
            <% end %>

            <div class="w-4/5 rounded-2xl p-4 ">
              <form phx-submit="submit">
                <textarea
                  id="content"
                  phx-hook="SubmitOnCmdEnter"
                  name="content"
                  class="block resize-none w-full rounded-2xl bg-gray-100 p-4 placeholder-gray-400 placeholder:text-sm placeholder:italic border-none outline-none"
                  placeholder="Enter a message..."
                  rows="6"
                />
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_open, &(!&1))}
  end

  def render_messages(assigns) do
    ~H"""
    <%= for %{from: from, content: content} <- @messages do %>
      <div class="flex">
        <div>from: {from}</div>
        <div>content: {content}</div>
      </div>
    <% end %>
    """
  end
end
