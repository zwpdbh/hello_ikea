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
      # assign [] to messages to indicate it is a new chat,
      # set it nil later to indicate it is in a conversation because in conversation we use streams.messages
      |> assign(:messages, [])
      |> stream(
        :conversations,
        Hello.Chat.my_conversations!(actor: socket.assigns.current_user, stream?: true)
      )
      |> assign(:current_user_id, socket.assigns.current_user.id)
      |> assign(:can_submit, false)
      |> assign(:llm_option, :local)

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

            <.render_histories
              conversations={@streams.conversations}
              current_conversation={@conversation}
            />
          </div>
        </div>

        <div class="flex flex-1 flex-col overflow-hidden ">
          <div class="p-4 flex flex-col flex-1 overflow-hidden relative">
            <div class="absolute top-1 left-1 bg-blue-200 text-sm font-bold rounded">
              <form phx-change="llm_option">
                <select name="source">
                  <option value="local">Local</option>
                  <option value="openai">OpenAI</option>
                </select>
              </form>
            </div>
            <%= if @messages == [] do %>
              <div class="flex flex-1 items-center justify-center">
                <div class="w-4/5 rounded-2xl p-4">
                  <.render_message_form message_form={@message_form} can_submit={@can_submit}>
                  </.render_message_form>
                </div>
              </div>
            <% else %>
              <.render_messages messages={@streams.messages} current_user_id={@current_user_id} />
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
    <div
      id="conversation-history-list"
      class="flex flex-1 flex-col overflow-y-auto space-y-1 "
      phx-update="stream"
    >
      <%= for {id, each_conversation} <- @conversations do %>
        <div
          id={id}
          class={
            if @current_conversation && each_conversation.id == @current_conversation.id do
              "bg-gray-300 hover:bg-gray-300 p-1 rounded font-medium flex"
            else
              "hover:bg-gray-200 p-1 rounded flex"
            end
          }
        >
          <.link href={~p"/chats/#{each_conversation.id}"}>
            <%= if each_conversation.title do %>
              {each_conversation.title}
            <% else %>
              {"Chat #{each_conversation.id}"}
            <% end %>
          </.link>

          <button
            phx-click={"leave_conversation:#{each_conversation.id}"}
            class="pl-2 transform items-center justify-center text-sm hover:text-red-600 rounded-full transition-all duration-200 ease-in-out"
          >
            <.icon class="w-4 h-4 text-gray-500 hover:text-red-600" name="hero-x-mark" />
          </button>
        </div>
      <% end %>
    </div>
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
    <div
      id="conversation-messages-container"
      phx-update="stream"
      class="flex flex-1 flex-col-reverse px-6 py-4 gap-2 scroll-smooth"
    >
      <%= for {id, msg} <- @messages do %>
        <%= if msg.sender_id == @current_user_id do %>
          <.render_message_from_me message={msg} id={id}></.render_message_from_me>
        <% else %>
          <.render_message_from_others message={msg} id={id}></.render_message_from_others>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp render_message_from_me(assigns) do
    ~H"""
    <div id={@id} class="flex gap-3 justify-end">
      <div class="px-4 py-2 rounded-xl max-w-xl bg-blue-400 text-white">
        {@message.content}
      </div>
      <div class="flex-shrink-0">
        <div class="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center">
          <.icon name="hero-user-solid" class="w-6 h-6 text-gray-800" />
        </div>
      </div>
    </div>
    """
  end

  defp render_message_from_others(assigns) do
    ~H"""
    <div id={@id} class="flex gap-3 justify-start">
      <div class="flex-shrink-0">
        <div class="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center">
          <img
            src="https://github.com/ash-project/ash_ai/blob/main/logos/ash_ai.png?raw=true"
            alt="Agent"
            class="w-8 h-8 rounded-full"
          />
        </div>
      </div>
      <div class="px-4 py-2 rounded-xl max-w-xl bg-gray-200 text-black">
        {@message.content}
      </div>
    </div>
    """
  end

  def handle_params(%{"conversation_id" => conversation_id}, _, socket) do
    conversation =
      Hello.Chat.get_conversation_by_id!(conversation_id, actor: socket.assigns.current_user)

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
    |> assign(:messages, nil)
    |> stream(:messages, Hello.Chat.message_history!(conversation.id, stream?: true))
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
      |> stream(:messages, [])
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
  def handle_event("leave_conversation:" <> conversation_id, _params, socket) do
    Logger.warning(
      "->>TODO: delete conversation: #{conversation_id} for user: #{inspect(socket.assigns.current_user)}"
    )

    Hello.Chat.leave_conversation!(conversation_id, actor: socket.assigns.current_user)

    {:noreply, socket}
  end

  @impl true
  def handle_event("llm_option", %{"source" => value}, socket) do
    option =
      case value do
        "openai" -> :openai
        "local" -> :local
      end

    {:noreply, socket |> assign(:llm_option, option)}
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
        if socket.assigns.conversation do
          socket
          |> assign_message_form()
          |> assign(:messages, nil)
          |> stream_insert(:messages, message, at: 0)
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

  # @impl true
  # def handle_info(
  #       %Phoenix.Socket.Broadcast{
  #         topic: "chat:messages:" <> conversation_id,
  #         payload: message
  #       },
  #       socket
  #     ) do
  #   if socket.assigns.conversation && socket.assigns.conversation.id == conversation_id do
  #     {:noreply, stream_insert(socket, :messages, message, at: 0)}
  #   else
  #     {:noreply, socket}
  #   end
  # end
end
