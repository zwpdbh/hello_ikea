defmodule HelloWeb.ChatLive.ChatArea do
  use HelloWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:can_submit, false)

    {:ok, socket}
  end

  @impl true
  def update(%{conversation: nil, current_user: current_user} = _assigns, socket) do
    socket =
      socket
      |> assign(:messages, [])
      |> assign(:conversation, nil)
      |> assign(:current_user, current_user)
      |> assign_message_form()

    # socket.assigns |> dbg()
    {:ok, socket}
  end

  @impl true
  def update(%{conversation: conversation, current_user: current_user} = _assigns, socket) do
    socket =
      socket
      |> assign(:messages, "in-message-streams")
      |> stream(:messages, Hello.Chat.message_history!(conversation.id, stream?: true))
      |> assign(:conversation, conversation)
      |> assign(:current_user, current_user)
      |> assign_message_form()

    # socket.assigns |> dbg()
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
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
              <.render_message_form
                message_form={@message_form}
                conversation={@conversation}
                can_submit={@can_submit}
                myself={@myself}
              >
              </.render_message_form>
            </div>
          </div>
        <% else %>
          <.render_messages
            messages={@streams.messages}
            current_user_id={@current_user.id}
            myself={@myself}
          />
          <div class="rounded-2xl p-4">
            <.render_message_form
              message_form={@message_form}
              can_submit={@can_submit}
              myself={@myself}
            >
            </.render_message_form>
          </div>
        <% end %>
      </div>
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
      phx-target={@myself}
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
  def handle_event("validate_message", %{"form" => %{"content" => content} = form_data}, socket) do
    {:noreply,
     socket
     |> assign(:message_form, AshPhoenix.Form.validate(socket.assigns.message_form, form_data))
     |> assign(:can_submit, String.trim(content) != "")}
  end

  @impl true
  # it is used to handle user submit empty content
  def handle_event("send_message", %{"form" => %{"content" => ""}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("send_message", %{"form" => form_data}, socket) do
    case AshPhoenix.Form.submit(
           socket.assigns.message_form,
           params: form_data
         )
         |> dbg() do
      {:ok, message} ->
        if socket.assigns.conversation do
          socket =
            socket
            |> assign(:messages, nil)
            |> stream_insert(:messages, message, at: 0)

          {:noreply, socket}
        else
          {:noreply,
           socket
           |> push_navigate(to: ~p"/chats/#{message.conversation_id}")}
        end

      {:error, form} ->
        {:noreply, assign(socket, :message_form, form)}
    end
  end

  # @impl true
  # def handle_event(
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

  # @impl true
  # def handle_event({:leave_conversation, conversation_id}, socket) do
  #   Logger.warning(
  #     "->>TODO: delete conversation: #{conversation_id} for user: #{inspect(socket.assigns.current_user)}"
  #   )

  #   Hello.Chat.leave_conversation!(conversation_id, actor: socket.assigns.current_user)

  #   {:noreply, socket}
  # end

  # def handle_event(
  #       %Phoenix.Socket.Broadcast{
  #         topic: "chat:conversations:" <> _,
  #         payload: conversation
  #       },
  #       socket
  #     ) do
  #   socket =
  #     if socket.assigns.conversation && socket.assigns.conversation.id == conversation.id do
  #       assign(socket, :conversation, conversation)
  #     else
  #       socket
  #     end

  #   {:noreply, stream_insert(socket, :conversations, conversation)}
  # end

  defp assign_message_form(socket) do
    args =
      case socket.assigns.conversation do
        nil ->
          %{
            sender: socket.assigns.current_user
          }

        conversation ->
          %{
            sender: socket.assigns.current_user,
            conversation_id: conversation.id
          }
      end

    form =
      Hello.Chat.form_to_create_message(
        actor: socket.assigns.current_user,
        private_arguments: args
      )
      |> AshPhoenix.Form.ensure_can_submit!()
      |> to_form()

    socket |> assign(:message_form, form)
  end
end
