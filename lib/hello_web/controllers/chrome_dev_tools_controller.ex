defmodule HelloWeb.ChromeDevToolsController do
  use HelloWeb, :controller

  def index(conn, _params) do
    json(conn, %{})
  end
end
