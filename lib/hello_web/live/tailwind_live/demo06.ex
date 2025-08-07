defmodule HelloWeb.TailwindLive.Demo06 do
  use HelloWeb, :live_view
  import HelloWeb.Layouts

  @impl true
  def mount(_params, _session, socket) do
    messages =
      [
        %{role: "assistant", from: "Bot", content: "This is cool!", style: "bot"},
        %{role: "user", from: "You", content: "I am noob", style: "current"},
        %{role: "user", from: "User02", content: "It is fine", style: "other"}
      ]
      |> List.duplicate(1)
      |> List.flatten()

    histories =
      1..2
      |> Enum.map(fn x -> "chat history #{x}" end)

    socket =
      socket
      |> assign(:sidebar_open, true)
      |> assign(:messages, messages)
      |> assign(:histories, histories)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen bg-orange-200">
      <.app_header {assigns}></.app_header>
      <div class="bg-white flex flex-1 bg-teal-200">
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
            <%= for each_history <- @histories do %>
              <div class="hover:bg-gray-200 p-1 rounded">{each_history}</div>
            <% end %>
          </div>
        </div>

        <div class="flex-1 bg-gray-50 overflow-hidden flex flex-col">
          <div class="p-4 flex-1 flex ">
            <div class={
              if @messages == [],
                do: "flex-1 flex items-center justify-center",
                else: "flex-1 flex flex-col"
            }>
              <%= if @messages != [] do %>
                <div class="flex-1 overflow-y-auto rounded-lg p-2 mb-4">
                  <.render_messages messages={@messages} />
                </div>
              <% end %>

              <div class={if @messages == [], do: "w-4/5 rounded-2xl p-4 ", else: "rounded-2xl p-4 "}>
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
    </div>
    """
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_open, &(!&1))}
  end

  def render_messages(assigns) do
    ~H"""
    <div class="space-y-3">
      <%= for msg <- @messages do %>
        <div class={
            "flex gap-2 " <>
            if(msg.style == "current", do: "justify-end", else: "justify-start")
          }>
          <%= if msg.style != "current" do %>
            <div class="flex-shrink-0 w-8 h-8 bg-gray-400 rounded-full flex items-center justify-center text-white text-xs font-bold">
              {String.first(msg.from)}
            </div>
          <% end %>

          <div class={
              "max-w-xs lg:max-w-md px-4 py-2 rounded-lg text-sm " <>
              case msg.style do
                "current" -> "bg-blue-500 text-white rounded-tr-none"
                "other" -> "bg-gray-300 text-gray-800 rounded-tl-none"
                "bot" -> "bg-green-500 text-white rounded-tl-none"
                _ -> "bg-gray-200"
              end
            }>
            <p>{msg.content}</p>
          </div>

          <%= if msg.style == "bot" do %>
            <div class="flex-shrink-0 ml-1">
              <.icon name="hero-cog-6-tooth" class="w-5 h-5 text-gray-500" />
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
