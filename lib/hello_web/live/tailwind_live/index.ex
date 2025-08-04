defmodule HelloWeb.TailwindLive.Index do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Layouts.app {assigns}>
        Tailwind CSS demos
        <ul>
          <li>
            <.link navigate={~p"/tailwind/demo01"} class="text-blue-500 hover:underline">
              Demo 01 -- main elements
            </.link>
          </li>
          <li>
            <.link navigate={~p"/tailwind/demo02"} class="text-blue-500 hover:underline">
              Demo 02 -- layouts: flexbox
            </.link>
          </li>
          <li>
            <.link navigate={~p"/tailwind/demo03"} class="text-blue-500 hover:underline">
              Demo 03 -- layouts: grid
            </.link>
          </li>
          <li>
            <.link navigate={~p"/tailwind/demo04"} class="text-blue-500 hover:underline">
              Demo04 -- My Resume
            </.link>
          </li>
          <li>
            <.link navigate={~p"/tailwind/demo05"} class="text-blue-500 hover:underline">
              Demo04 -- My Resume using liveview components
            </.link>
          </li>
        </ul>
      </Layouts.app>
    </div>
    """
  end
end
