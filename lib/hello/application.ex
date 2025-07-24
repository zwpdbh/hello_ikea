defmodule Hello.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HelloWeb.Telemetry,
      Hello.Repo,
      {DNSCluster, query: Application.get_env(:hello, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:hello, :ash_domains),
         Application.fetch_env!(:hello, Oban)
       )},
      {Phoenix.PubSub, name: Hello.PubSub},
      # Start a worker by calling: Hello.Worker.start_link(arg)
      # {Hello.Worker, arg},
      # Start to serve requests, typically the last entry
      HelloWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :hello]},
      Hello.LLM.Config,
      {Nx.Serving, serving: serving(), name: MyNxServing},
      {Nx.Serving,
       serving: Hello.Rag.Serving.build_embedding_serving(), name: MyEmbeddingServing},
      {Nx.Serving, serving: Hello.Rag.Serving.build_llm_serving(), name: MyLLMServing}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hello.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelloWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def serving do
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "finiteautomata/bertweet-base-emotion-analysis"})

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "vinai/bertweet-base"})

    Bumblebee.Text.text_classification(model_info, tokenizer,
      compile: [batch_size: 10, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end
end
