# Different from ChatOpenaiLive, it is chat with local LLM
defmodule HelloWeb.ChatLive.Index do
  require Logger

  use HelloWeb, :live_view
  import HelloWeb.Layouts

  on_mount {HelloWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    HelloWeb.Endpoint.subscribe("chat:conversations:#{socket.assigns.current_user.id}")

    Hello.Chat.my_conversations!(actor: socket.assigns.current_user, stream?: false)

    socket =
      socket
      |> assign(:current_user_id, socket.assigns.current_user.id)
      |> assign(:conversation, nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen">
      <.app_header {assigns}></.app_header>

      <div class="bg-white flex flex-1 overflow-hidden">
        <.live_component
          module={HelloWeb.ChatLive.ChatSidebar}
          id="chat-sidebar"
          conversation={@conversation}
          current_user={@current_user}
        />

        <.live_component
          module={HelloWeb.ChatLive.ChatArea}
          id="chat-area"
          conversation={@conversation}
          current_user={@current_user}
        />
      </div>
    </div>
    """
  end

  def handle_params(%{"conversation_id" => conversation_id}, _, socket) do
    conversation =
      Hello.Chat.get_conversation!(conversation_id, actor: socket.assigns.current_user)

    # cond do → checks multiple conditions and runs the first matching block.
    cond do
      socket.assigns[:conversation] && socket.assigns[:conversation].id == conversation.id ->
        :ok

      socket.assigns[:conversation] ->
        HelloWeb.Endpoint.unsubscribe("chat:messages:#{socket.assigns.conversation.id}")
        HelloWeb.Endpoint.subscribe("chat:messages:#{conversation.id}")

      true ->
        HelloWeb.Endpoint.subscribe("chat:messages:#{conversation.id}")
    end

    socket =
      socket
      |> assign(:conversation, conversation)
      |> assign(:messages, nil)
      |> stream(:messages, Hello.Chat.message_history!(conversation.id, stream?: true))

    {:noreply, socket}
  end

  @impl true
  def handle_params(_, _, socket) do
    if socket.assigns[:conversation] do
      HelloWeb.Endpoint.unsubscribe("chat:messages:#{socket.assigns.conversation.id}")
    end

    socket =
      socket
      |> assign(:conversation, nil)
      |> stream(:messages, [])

    {:noreply, socket}
  end

  @impl true
  def handle_info({:nav_to_conversation, %{conversation_id: conversation_id}}, socket) do
    {:noreply, socket |> push_patch(to: ~p"/chats/#{conversation_id}")}
  end
end
