defmodule HelloWeb.ChatLive.ChatSidebar do
  require Logger
  use HelloWeb, :live_component

  @impl true
  def mount(socket) do
    Logger.warning("->> mount is called")

    socket =
      socket
      |> assign(:sidebar_open, true)

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    Logger.warning("->> update is called")

    {:ok,
     socket
     |> stream(
       :conversations,
       Hello.Chat.my_conversations!(actor: assigns.current_user, stream?: true)
     )
     |> assign(:conversation, assigns.conversation)
     |> assign(:current_user, assigns.current_user)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={"transition-all duration-300 flex flex-col p-2 space-y-2 bg-gray-100 " <> if(@sidebar_open, do: "w-64", else: "w-16 overflow-hidden")}>
      <div class="flex justify-end">
        <button phx-target={@myself} phx-click="toggle_sidebar" class="p-1 hover:bg-gray-400 rounded">
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

      <div class={"flex-1 flex flex-col space-y-1 overflow-hidden #{if @sidebar_open, do: "", else: "hidden"}"}>
        <div
          class="flex items-center gap-1 hover:bg-gray-200 p-1 rounded text-sm"
          phx-click="new_chat"
        >
          <.icon name="hero-pencil-square" />
          <span>New chat</span>
        </div>

        <div class="flex items-center gap-1 hover:bg-gray-200 p-1 rounded">
          <.icon name="hero-magnifying-glass" />
          <form action="">
            <input
              type="text"
              placeholder="Search"
              class="bg-transparent w-full outline-none text-sm text-gray-700 placeholder-gray-500"
              phx-debounce="500ms"
              phx-change="search"
              name="query"
              value=""
            />
          </form>
        </div>

        <div class="text-gray-400 font-bold mt-2 text-sm">
          History
        </div>

        <div
          id="conversation-history-list"
          class="flex flex-1 flex-col overflow-y-auto space-y-1"
          phx-update="stream"
        >
          <%= for {id, each_conversation} <- @streams.conversations do %>
            <div
              id={id}
              class={
                if @conversation && each_conversation.id == @conversation.id do
                  "bg-gray-300 hover:bg-gray-300 p-1 rounded font-medium flex"
                else
                  "hover:bg-gray-200 p-1 rounded flex"
                end
              }
            >
              <button
                phx-click="nav_to_conversation"
                phx-value-conversation_id={each_conversation.id}
                phx-target={@myself}
              >
                <%= if each_conversation.title do %>
                  {each_conversation.title}
                <% else %>
                  Chat {each_conversation.id}
                <% end %>
              </button>

              <button
                phx-click={"leave_conversation:#{each_conversation.id}"}
                class="pl-2 transform items-center justify-center text-sm hover:text-red-600 rounded-full transition-all duration-200 ease-in-out"
              >
                <.icon class="w-4 h-4 text-gray-500 hover:text-red-600" name="hero-x-mark" />
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("nav_to_conversation", %{"conversation_id" => _conversation_id}, socket) do
    # pop event to liveview

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, socket |> assign(:sidebar_open, !socket.assigns.sidebar_open)}
  end

  @impl true
  def handle_event("new_chat", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/chats")}
  end

  @impl true
  def handle_event("search", %{"query" => text}, socket) do
    Logger.info("->> todo: search -- #{text}")

    {:noreply, socket}
  end
end
