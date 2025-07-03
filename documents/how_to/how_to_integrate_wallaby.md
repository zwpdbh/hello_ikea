# How to integrate Wallaby

To learn TDD with Phoenix development. 

## How to configure [wallaby](https://github.com/elixir-wallaby/wallaby)


1. Install [Chrome for Testing](https://googlechromelabs.github.io/chrome-for-testing/) 
   - Install `chrome` -- `linux64` from the dashboard.
   - Install `chromedriver` -- `linux64` from the same dashboard.
  
  Assume, we will run `mix test` in Ubuntu22.04. So, `unzip` them. 

2. In `mix.exs`

```elixir 
{:wallaby, "~> 0.30", runtime: false, only: :test}
```

3. In `test_helper.exs`

```elixir 
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, helloWeb.Endpoint.url())
```
   
4. In `test.exs` 

```elixir 
config :hello, helloWeb.Endpoint,
  ...
  # change from false to true
  server: true

config :wallaby, driver: Wallaby.Chrome

config :wallaby,
  chromedriver: [
    # use chmod +x to make them executable
    path: "/home/zw/chromedriver-linux64/chromedriver",
    binary: "/home/zw/chrome-linux64/chrome"
  ]

config :wallaby, otp_app: :hello
config :hello, :sandbox, Ecto.Adapters.SQL.Sandbox
```

5. In `endpoint.ex`

```elixir 
defmodule helloWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hello

  # 1. add this at the very beginning
  if Application.compile_env(:hello, :sandbox, false) do
    plug Phoenix.Ecto.SQL.Sandbox
  end

  # ...
  # make sure the user_agent is passed in the connect_info
  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [:user_agent, session: @session_options]]
  )
```

6. Run `mix test` should show no error or warning.