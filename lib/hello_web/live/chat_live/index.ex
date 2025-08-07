# Different from ChatOpenaiLive, it is chat with local LLM
defmodule HelloWeb.ChatLive.Index do
  require Logger

  use HelloWeb, :live_view
  import HelloWeb.Layouts

  on_mount {HelloWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    HelloWeb.Endpoint.subscribe("chat:conversations:#{socket.assigns.current_user.id}")

    socket =
      socket
      |> assign(:sidebar_open, true)
      |> assign(:messages, [])
      |> stream(
        :conversations,
        Hello.Chat.my_conversations!(actor: socket.assigns.current_user, stream?: true)
      )
      |> assign(:current_user_id, socket.assigns.current_user.id)
      |> assign(:can_submit, false)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen">
      <.app_header {assigns}></.app_header>

      <div class="bg-white flex flex-1 overflow-hidden">
        <div class={"transition-all duration-300 flex flex-col p-2 space-y-2 bg-gray-100 " <> if(@sidebar_open, do: "w-64", else: "w-16 overflow-hidden")}>
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

          <div :if={@sidebar_open} class="flex-1 flex flex-col space-y-1 overflow-hidden">
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
            <%!-- <%= if @streams.conversations != [] do %>

            <% end %> --%>
            <div
              id="conversation-history-list"
              class="flex flex-1 flex-col overflow-y-auto space-y-1 "
            >
              <.render_histories
                conversations={@streams.conversations}
                current_conversation={@conversation}
              />
            </div>
          </div>
        </div>

        <div class="flex flex-1 flex-col bg-gray-50 overflow-hidden">
          <div class="p-4 flex flex-col flex-1 overflow-hidden">
            <%= if @messages == [] do %>
              <div class="flex flex-1 items-center justify-center">
                <div class="w-4/5 rounded-2xl p-4">
                  <.render_message_form message_form={@message_form} can_submit={@can_submit}>
                  </.render_message_form>
                </div>
              </div>
            <% else %>
              <div class="flex-1 overflow-y-auto rounded-lg bg-white p-2 mb-4">
                <.render_messages messages={@messages} current_user_id={@current_user_id} />
              </div>

              <div class="rounded-2xl p-4">
                <.render_message_form message_form={@message_form} can_submit={@can_submit}>
                </.render_message_form>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def render_histories(assigns) do
    ~H"""
    <%= for {_id, each_conversation} <- @conversations do %>
      <.link
        class={
          if @current_conversation && each_conversation.id == @current_conversation.id do
            "bg-gray-300 hover:bg-gray-300 p-1 rounded font-medium"
          else
            "hover:bg-gray-200 p-1 rounded"
          end
        }
        href={~p"/chats/#{each_conversation.id}"}
      >
        <%= if each_conversation.title do %>
          {each_conversation.title}
        <% else %>
          {"Chat #{each_conversation.id}"}
        <% end %>
      </.link>
    <% end %>
    """
  end

  def render_message_form(assigns) do
    ~H"""
    <.form
      :let={form}
      for={@message_form}
      phx-submit="send_message"
      phx-change="validate_message"
      class="relative"
    >
      <textarea
        id="message_content"
        phx-hook="SubmitOnCmdEnter"
        class="block resize-none w-full rounded-2xl bg-gray-100 p-4 pr-12 placeholder-gray-400 placeholder:text-sm placeholder:italic border-none outline-none"
        placeholder="Enter a message..."
        rows="6"
        name={form[:content].name}
        value={form[:content].value}
      />
      <button
        type="submit"
        class="absolute bottom-3 right-4 p-1 text-blue-500 hover:text-blue-700 focus:outline-none"
        disabled={!@can_submit}
      >
        <.icon name="hero-paper-airplane" class="w-5 h-5 rotate-45" />
      </button>
    </.form>
    """
  end

  defp render_messages(assigns) do
    ~H"""
    <div class="space-y-3">
      <%= for msg <- @messages do %>
        <div class={
          "flex gap-2 " <>
          if(msg.sender_id == @current_user_id, do: "justify-end", else: "justify-start")
        }>
          <%= if msg.sender_id != @current_user_id do %>
            <div class="flex-shrink-0 w-8 h-8 bg-gray-400 rounded-full flex items-center justify-center text-white text-xs font-bold">
              {sender_initial(msg)}
            </div>
          <% end %>

          <div class={
            "max-w-xs lg:max-w-md px-4 py-2 rounded-lg text-sm " <>
            case sender_type(msg, @current_user_id) do
              :me -> "bg-blue-500 text-white rounded-tr-none"
              :other -> "bg-gray-300 text-gray-800 rounded-tl-none"
              :bot -> "bg-green-500 text-white rounded-tl-none"
            end
          }>
            <p>{msg.content}</p>
          </div>

          <%= if sender_type(msg, @current_user_id) == :bot do %>
            <div class="flex-shrink-0 ml-1">
              <.icon name="hero-cog-6-tooth" class="w-5 h-5 text-gray-500" />
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp sender_initial(%{sender_type: :bot}), do: "🤖"
  defp sender_initial(%{sender_type: _, content: _}), do: "👤"

  defp sender_type(msg, current_user_id) do
    cond do
      msg.sender_type == :bot -> :bot
      msg.sender_id == current_user_id -> :me
      true -> :other
    end
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

    socket
    |> assign(:conversation, conversation)
    |> assign(:messages, Hello.Chat.message_history!(conversation.id, stream?: false))
    |> assign_message_form()
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_params(_, _, socket) do
    if socket.assigns[:conversation] do
      HelloWeb.Endpoint.unsubscribe("chat:messages:#{socket.assigns.conversation.id}")
    end

    socket =
      socket
      |> assign(:conversation, nil)
      |> assign_message_form()

    {:noreply, socket}
  end

  defp assign_message_form(socket) do
    form =
      if socket.assigns.conversation do
        Hello.Chat.form_to_create_message(
          actor: socket.assigns.current_user,
          private_arguments: %{conversation_id: socket.assigns.conversation.id}
        )
        |> to_form()
      else
        Hello.Chat.form_to_create_message(actor: socket.assigns.current_user)
        |> to_form()
      end

    socket
    |> assign(:message_form, form)
  end

  @impl true
  def handle_event("validate_message", %{"form" => message_form_params}, socket) do
    socket =
      socket
      |> assign(
        :message_form,
        AshPhoenix.Form.validate(socket.assigns.message_form, message_form_params)
      )

    {:noreply, socket}
  end

  @impl true
  # it is used to handle user submit empty content
  def handle_event("send_message", %{"form" => %{"content" => ""}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("send_message", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.message_form,
           params:
             params
             |> Map.put("sender_type", :user)
         ) do
      {:ok, message} ->
        updated_messages = [message] ++ socket.assigns.messages

        if socket.assigns.conversation do
          socket
          |> assign_message_form()
          |> assign(:messages, updated_messages)
          |> then(&{:noreply, &1})
        else
          {:noreply,
           socket
           |> push_navigate(to: ~p"/chats/#{message.conversation_id}")}
        end

      {:error, form} ->
        {:noreply, assign(socket, :message_form, form)}
    end
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_open, &(!&1))}
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
