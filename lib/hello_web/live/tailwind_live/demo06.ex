defmodule HelloWeb.TailwindLive.Demo06 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:sidebar_open, true)}
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
        <div :if={@sidebar_open} class="space-y-2">
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
      
    <!-- Main Content -->
      <div class="flex-1 bg-gray-50 p-4 overflow-auto">
        <div>let's chat</div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_open, &(!&1))}
  end
end
