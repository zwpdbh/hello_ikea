defmodule HelloWeb.TailwindLive.Demo02 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-20 bg-blue-200">
      <h2 class="mb-4">Box Properties</h2>
      <p>Box properties includes: background, border, rounding, shadow</p>
      <div class="p-10 bg-purple-400 rounded-lg border-purple-500 border shadow-lg">I am a box</div>
    </div>
    """
  end
end
