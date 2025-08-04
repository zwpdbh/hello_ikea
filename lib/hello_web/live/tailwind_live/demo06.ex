defmodule HelloWeb.TailwindLive.Demo06 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen bg-white grid grid-cols-8 gap-4">
      <div class="bg-gray-100 p-2 space-y-2 flex flex-col">
        <div class="flex justify-end">
          <.icon name="hero-adjustments-horizontal" class="hover:bg-gray-400" />
        </div>

        <div>
          <div class="flex items-center gap-1 hover:bg-gray-200">
            <.icon name="hero-pencil-square" />
            <span>new chat</span>
          </div>
          <div class="hover:bg-gray-200">
            <.icon name="hero-magnifying-glass" /> search
          </div>
          <div class="text-gray-400 font-bold mt-2">
            History
          </div>
          <div class="hover:bg-gray-200">chat history 01</div>
          <div class="hover:bg-gray-200">chat history 02</div>
          <div class="hover:bg-gray-200">chat history 03</div>
        </div>
      </div>

      <div class="col-start-2 col-span-end">
        <div>let's chat</div>
      </div>
    </div>
    """
  end
end
