defmodule Hello.LLMProvider.Config do
  use GenServer

  @moduledoc """
  Loads and holds LLM/OpenAI config from app environment at startup.
  Use `Hello.LLMProvider.Config.get/0` to retrieve it.
  """

  defstruct api_key: nil,
            base_url: nil,
            embedding_url: nil,
            embedding_model: nil,
            image_gen_url: nil,
            chat_model: nil,
            chat_endpoint: nil,
            response_endpoint: nil

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
    base_url = config[:base_url]

    state = %__MODULE__{
      api_key: config[:api_key],
      base_url: config[:base_url],
      embedding_model: config[:embedding_model],
      chat_model: config[:chat_model],
      embedding_url: "#{base_url}/embeddings",
      image_gen_url: "#{base_url}/images/generations",
      chat_endpoint: "#{base_url}/chat/completions",
      response_endpoint: "#{base_url}/responses"
    }

    {:ok, state} |> dbg()
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
