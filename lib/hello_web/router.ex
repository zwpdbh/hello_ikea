defmodule HelloWeb.Router do
  use HelloWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HelloWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/", HelloWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {HelloWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {HelloWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {HelloWeb.LiveUserAuth, :live_no_user}

      live "/", HomeLive
      live "/chats", ChatLive.Index, :index
      live "/chats_openai", ChatOpenaiLive.Index, :index
      live "/bumblebee", BumblebeeLive.Index, :index

      # For demo different tailwind practises
      live "/tailwind", TailwindLive.Index, :index
      live "/tailwind/demo01", TailwindLive.Demo01, :demo01
      live "/tailwind/demo02", TailwindLive.Demo02, :demo02
      live "/tailwind/demo03", TailwindLive.Demo03, :demo03
      live "/tailwind/demo04", TailwindLive.Demo04, :demo04
      live "/tailwind/demo05", TailwindLive.Demo05, :demo05
    end
  end

  scope "/", HelloWeb do
    pipe_through :browser

    get "/.well-known/appspecific/com.chrome.devtools.json", ChromeDevToolsController, :index

    auth_routes AuthController, Hello.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{HelloWeb.LiveUserAuth, :live_no_user}],
                  overrides: [HelloWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [HelloWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the confirmation strategy
    confirm_route Hello.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      overrides: [HelloWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(Hello.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      overrides: [HelloWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )
  end

  # Other scopes may use custom stacks.
  scope "/api", HelloWeb do
    pipe_through :api

    post "/chat", ChatController, :stream
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hello, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HelloWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Application.compile_env(:hello, :dev_routes) do
    import AshAdmin.Router

    scope "/admin" do
      pipe_through :browser

      ash_admin "/"
    end
  end
end
