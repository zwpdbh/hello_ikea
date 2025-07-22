# How to run scenario test request from outside 

- Currently, `ScenarioTestRunner` represent a running scenario test process. 
- It should also represent a running scenario test from outside of this web application, say Aurora.
- In this case:
  - the user from Aurora send a request including a scenario test configuration.
  - web app will create a `ScenarioTestRunner` process to represent such scenario test.
  - web app keep connection with the client using websocket. 
    - web app update the available cluster to the client.
    - client update the scenario test status to the web app.  
- So, in general, the ScenarioTestRunner should abstract the idea 
  that some process (our system process or outside system process) is running a scenario test. 
  - If the process is our system, we run it using `handle_cast -- perform_scenario_test_task`.
  - If the process is outside system, we need to keep connection with that process and update `ScenarioTestRunner` status accordingly.


## My current plan

1. Client send a post request to this Phoenix web application to create a `AcstorScenario`. 
   - If there is already an existing same `AcstorScenario`, return ok.
   - Create a `ScenarioReport` with name like `Aurora#{TodayDate}`.
   - Create a `ScenarioTest` based on `AcstorScenario` and `ScenarioReport`. 
   - Client and web app keep real-time connection via WebSocket.
2. Run scenario test
   - As we have a `ScenarioTest` created, we can start running it using `ScenarioTestRunner`.
3. Based on different situation, we need to use different `ObanWorker`

```elixir
def handle_cast(
     :perform_scenario_test_task,
     %__MODULE__{scenario_test: scenario_test, cluster_id: cluster_id} = state
   ) do
 %{scenario_test_id: scenario_test.id, cluster_id: cluster_id}
 |> Hello.Scenarios.ScenarioTestWorker.new()
 |> Oban.insert()

 {:noreply, state}
end
```

Such that, the new `ExternalScenarioTestWorker` need to use websocket to sync with Aurora client for external scenario test execution.


## Some consideration 

1. WebSocket Layer Suggestion:
  - Consider using Phoenix Channels with a dedicated ScenarioTestRunnerSocket module to handle the real-time updates.
  - Each ScenarioTestRunner should have its own channel topic to isolate communications (e.g. "scenario_test_runner:{runner_id}")
  
2. `ExternalScenarioTestWorker`
  - Establishes WebSocket connection to Aurora
  - Implements heartbeat mechanism
  - Handles status updates via Phoenix Channel
  
3. Add channel handling in your Endpoint:

```elixir 
defmodule HelloWeb.UserSocket do
  channel "scenario_test_runner:*", HelloWeb.ScenarioTestRunnerChannel
end
```

4. Process Management Considerations:

- Use Registry to track ScenarioTestRunner processes
- Implement proper cleanup when external tests complete/fail
- Add authentication to WebSocket connection to prevent unauthorized status updates


The plan needs clearer separation between:
- Internal test execution (direct control)
- External test coordination (status monitoring via WebSocket)


## Implementation 

1.  First implement the Channel (WebSocket communication):
  
```elixir 
defmodule HelloWeb.ScenarioTestRunnerChannel do
  use Phoenix.Channel

  def join("scenario_test_runner:" <> runner_id, _params, socket) do
    if Registry.lookup(Hello.ScenarioTestRunnerRegistry, runner_id) != [] do
      {:ok, assign(socket, :runner_id, runner_id)}
    else
      {:error, %{reason: "invalid_test_runner"}}
    end
  end

  def handle_in("status_update", payload, socket) do
    # Forward external test updates to ScenarioTestRunner
    Hello.Scenarios.ScenarioTestRunner.handle_external_update(
      socket.assigns.runner_id,
      payload
    )
    {:noreply, socket}
  end

  def handle_out("cluster_update", payload, socket) do
    push(socket, "cluster_update", payload)
    {:noreply, socket}
  end
end
```

2.  Then implement the External Worker(ObanWorker):
  
```elixir 
defmodule Hello.Scenarios.ExternalScenarioTestWorker do
  use Oban.Worker, queue: :external_scenario_tests

  alias HelloWeb.Endpoint
  
  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"scenario_test_id" => test_id}}) do
    # Establish WS connection to Aurora
    with {:ok, _} = connect_to_aurora(test_id),
         {:ok, _} = setup_heartbeat(test_id) do
      :ok
    else
      error -> handle_connection_error(test_id, error)
    end
  end

  defp connect_to_aurora(test_id) do
    # Implementation specific to Aurora's WS API
    Endpoint.broadcast!("scenario_test_runner:#{test_id}", "cluster_update", %{status: "connected"})
  end

  defp setup_heartbeat(test_id) do
    # Implement periodic status checks
    Process.send_after(self(), :heartbeat, 30_000)
    {:ok, test_id}
  end
end
```

### Why this order?

- The channel establishes real-time communication before workers need it
- The worker implementation depends on channel being available for status updates
- This creates an end-to-end flow:
  - Client connects via WebSocket
  - External worker maintains Aurora connection
  - Both use Channel for bi-directional updates

After these, implement the Registry integration and authentication middleware for the WebSocket connection. Would you like me to show those implementations next?


### What is the differences between WebSocket and gRPC for sync status? 

- For your specific case of coordinating external scenario tests with Aurora, 
  WebSocket is the better choice due to existing Phoenix infrastructure and browser-friendly nature.
  Looks like:
  Client <--WS--> Phoenix Channel <--> ScenarioTestRunner

- For Status Synchronization:
  - WebSocket Pros
    - Native browser support
    - Simple message-based API
    - Built for real-time updates
    - Phoenix Channels provide PubSub out-of-box
    - Better for frequent small updates
- gRPC Pros
  - Strong typing with Protobuf
  - Better for complex data structures
  - Built-in flow control
  - Efficient binary serialization
  - Better for mobile clients