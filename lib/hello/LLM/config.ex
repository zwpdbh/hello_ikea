defmodule Hello.LLM.Config do
  use GenServer

  @moduledoc """
  Loads and holds LLM/OpenAI config from app environment at startup.
  Use `Hello.Llm.Config.get/0` to retrieve it.
  """

  defstruct api_key: nil,
            embedding_url: nil,
            embedding_model: nil,
            image_gen_url: nil,
            chat_model: nil,
            chat_endpoint: nil

  @type t :: %__MODULE__{}

  # --- Public API ---

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec get() :: %__MODULE__{}
  def get do
    GenServer.call(__MODULE__, :get)
  end

  # --- GenServer Callbacks ---

  @impl true
  def init(_init_arg) do
    config = Application.get_env(:hello, :llm, [])

    state = %__MODULE__{
      api_key: config[:api_key],
      embedding_url: config[:embedding_url],
      embedding_model: config[:embedding_model],
      image_gen_url: config[:image_gen_url],
      chat_model: config[:chat_model],
      chat_endpoint: config[:chat_endpoint]
    }

    {:ok, state} |> dbg()
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
