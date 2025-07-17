# How to run scenarios using AKS pool

## Prerequisite -- AKS cluster pool

- A pool of AKS clusters is the set of clusters which status is `available`.
- When a AKS cluster is created using `CreateAksClusterWorker` which is an `Oban.Worker`.

```elixir 
defmodule HelloWeb.AksClusterLive.FormComponent do
  # ... other code 
  defp save_aks_cluster(socket, :new, aks_cluster_params) do
    # when create aks cluster, set it status to :creating
    aks_cluster_params =
      Map.put(aks_cluster_params, "status", :creating)
      |> IO.inspect(label: "->> aks_cluster_params")

    case AksManagement.create_aks_cluster(aks_cluster_params) do
      {:ok, aks_cluster} ->
        %{aks_cluster_id: aks_cluster.id}
        |> Hello.AksManagement.CreateAksClusterWorker.new()
        |> Oban.insert()

        notify_parent({:saved, aks_cluster})

        {:noreply,
         socket
         |> put_flash(
           :info,
           "AKS cluster with id: #{aks_cluster.id} is creating..."
         )
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end 
```

## Prerequisite -- scenario tests to run 

From an existing scenario group, a set of scenario tests are created and run using `Oban.Worker`.


```elixir 
defmodule Hello.Scenarios.ScenarioTestWorker do
  require Logger
  # the queue must be registered in config.exs
  use Oban.Worker, queue: :scenario_test
  alias Hello.AksManagement.AksCluster
  alias Hello.Scenarios.ScenarioTest

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"scenario_test_id" => id}}) do
    # Add more detailed log
    Logger.info("->> ScenarioTestWorker perform -- scenario_test_id: #{id}")

    scenario_test =
      Hello.Scenarios.get_scenario_test!(id)
      |> Hello.Repo.preload(:scenario_report)
      |> Hello.Repo.preload(:scenario)

    # we need to check if there are any available workers. If not, we need to wait.
    case Hello.AksManagement.get_available_cluster(scenario_test.scenario) do
      {:ok, cluster} ->
        # 1. if there is available cluster, use it to run the scenario test
        process_scenario_test_with_aks_cluster(scenario_test, cluster)

      {:error, :no_available_cluster} ->
        n_existing_clusters = Hello.AksManagement.list_aks_clusters() |> length()

        new_aks_cluster_params = %{
          name: "acstor-aks-cluster-#{n_existing_clusters}",
          status: :creating,
          node_pools: [
            %{
              name: "default-pool",
              node_sku: scenario_test.scenario.node_sku,
              num_of_node: scenario_test.scenario.num_of_node
            }
          ]
        }

        {:ok, cluster} = Hello.AksManagement.create_aks_cluster(new_aks_cluster_params)

        %{aks_cluster_id: cluster.id}
        |> Hello.AksManagement.CreateAksClusterWorker.new()
        |> Oban.insert()

        # 2.if there  is no available cluster, we need to wait until new compatiable cluster is ready.
        {:snooze, 30}
    end
  end

  defp process_scenario_test_with_aks_cluster(
         %ScenarioTest{} = scenario_test,
         %AksCluster{} = cluster
       ) do
    {:ok, updated_aks_cluster} =
      Hello.AksManagement.update_aks_cluster(cluster, %{status: :run_scenario_test})

    case execute_scenario_test(scenario_test) do
      {:ok, :succeed} ->
        Logger.info("->> Execute test for scenario: #{scenario_test.scenario_id} succeed")
        Hello.Scenarios.update_scenario_test(scenario_test, %{status: :success})

        Logger.info("->> Broadcast update to scenario_report:#{scenario_test.scenario_report.id}")

        HelloWeb.Endpoint.broadcast!(
          "scenario_report:#{scenario_test.scenario_report.id}",
          "update",
          %{
            scenario_test_id: scenario_test.id,
            status: :success
          }
        )

        Hello.AksManagement.update_aks_cluster(updated_aks_cluster, %{status: :available})

        {:ok, :succeed}

      {:error, reason} ->
        Logger.error("->> Error executing scenario test: #{scenario_test.id}, reason: #{reason}")
        Hello.Scenarios.update_scenario_test(scenario_test, %{status: :failed})

        # When execute_scenario_test failed, we need to save cluster to update it as :debug
        Hello.AksManagement.update_aks_cluster(updated_aks_cluster, %{status: :debug})

        {:error, reason}
    end
  end

  defp execute_scenario_test(scenario_test) do
    # First, update the scenario test status to "running"
    Hello.Scenarios.update_scenario_test(scenario_test, %{status: :running})

    try do
      # TODO: Replace with real logic
      # More specific log
      Logger.info("->> Executing test for scenario: #{scenario_test.scenario_id}")
      Process.sleep(Enum.random(10..20) * 1000)

      {:ok, :succeed}
    rescue
      e ->
        {:error, Exception.message(e)}
    end
  end
end
```

## How to run scenario test with AKS cluster 

- When a scenario test running, it is using a dedicated AKS cluster.  
- If there is a available AKS cluster, it using update that AKS cluster to `busy`. 
- When the scenario test running finished, it will update the AKS cluster to `available`. 
- If there is no available AKS cluster, it will wait until new compatiable cluster is ready.
- Question: when there is no available cluster, we need to create a new one and added to the AKS cluster pool. 
- Question: how to let scenario test wait until new compatiable cluster is ready? How to notify the scenario test that there is a new compatiable cluster?
- Is this a producer -- comsumer problem? where the AKS cluster could keep producing new AKS cluster, and the scenario test could keep consuming new AKS cluster?
  - should I use `GenStage` to solve this problem?

Based on above information, could you give me some suggestions?


## How to control back presure?

Let me clarify the producer-consumer relationship in this context.

Correction of Roles:
- Producers = AKS clusters (the resources being produced)
- Consumers = Scenario tests (the tasks consuming cluster resources)

Why This Makes Sense:

1. Cluster Producers:
   - Create/scale AKS cluster resources
   - Maintain a pool of available resources
   - "Produce" available capacity for tests

2. Test Consumers:
   - Consume cluster resources to execute tests
   - Generate demand for cluster resources
   - Need to wait when production can't keep up with demand

Key Flow:
1. Scenario tests (consumers) make requests for clusters
2. Cluster pool (producer):
   - Fulfills immediately if resources available
   - Triggers new cluster creation if needed
   - Notifies consumers when new capacity is ready

This model better matches:

- Production rate (cluster creation) vs consumption rate (test execution)
- Natural backpressure when test requests exceed cluster creation capacity
- Immediate notification system when new clusters come online

## References 

- [GenStage](https://hexdocs.pm/gen_stage/GenStage.html)
- [Elixir: a few things about GenStage I wish I knew some time ago](https://medium.com/@andreichernykh/elixir-a-few-things-about-genstage-id-wish-to-knew-some-time-ago-b826ca7d48ba)