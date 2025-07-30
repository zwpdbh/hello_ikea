defmodule HelloWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use HelloWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">Home</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <.link navigate={~p"/chats"} class="font-semibold text-gray-700 hover:text-gray-900">
              chat_bumblebee
            </.link>
          </li>
          <li>
            <.link
              navigate={~p"/chats_openai"}
              class="font-semibold text-gray-700 hover:text-gray-900"
            >
              chat_openai
            </.link>
          </li>
          <li>
            <.link navigate={~p"/bumblebee"} class="font-semibold text-gray-700 hover:text-gray-900">
              bumblebee
            </.link>
          </li>

          <li>
            <.link navigate={~p"/tailwind"} class="font-semibold text-gray-700 hover:text-gray-900">
              tailwind
            </.link>
          </li>

          <li>
            <.user_info current_user={@current_user} socket={@socket} />
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  def user_info(assigns) do
    ~H"""
    <div class="flex space-x-3 relative items-center">
      <%= if @current_user do %>
        {live_render(@socket, HelloWeb.NotificationsLive, sticky: true, id: :notifications_container)}

        <div class="!ml-8">
          <div
            tabindex="0"
            role="button"
            class="pr-0"
            phx-click={toggle("#user-menu")}
            phx-click-away={hide("#user-menu")}
          >
            <.avatar user={@current_user} />
          </div>
          <ul
            id="user-menu"
            tabindex="0"
            class="hidden z-[1] p-2 mt-3 shadow rounded-lg w-fit-content absolute right-0 bg-white text-sm"
          >
            <li class="border-b border-gray-300 p-2 pt-0">
              <p>
                Signed in as <strong class="whitespace-nowrap">{@current_user.email}</strong>
              </p>
            </li>
            <li class="border-b border-gray-300 p-2 pt-0">
              <.link navigate="/me" class="block">
                <strong class="whitespace-nowrap">My Settings</strong>
              </.link>
            </li>
            <li class="p-2 pb-0"><.link navigate="/sign-out" class="block">Sign out</.link></li>
          </ul>
        </div>
      <% else %>
        <.button_link navigate="/sign-in" size="xs">
          Sign In
        </.button_link>
        <span>or</span>
        <.button_link navigate="/register" size="xs">
          Register
        </.button_link>
      <% end %>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
