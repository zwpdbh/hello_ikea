defmodule HelloWeb.TailwindLive.Demo04 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      My Resume
    </div>
    """
  end
end
