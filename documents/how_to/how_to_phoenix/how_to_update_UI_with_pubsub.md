# How to update UI with pubsub 

When we click the button `Run Scenarios` for a scenario group.
- It generate a scenario report with link.
- User click that link to be guided to the report page. 

The goal is in the report page, the user can see the update of each scenario test in real time. 

## Where to send the message? 

We want to update the status of scenario test when it is finished. So, we do it in `Hello.Scenarios.ScenarioTestWorker`.

```elixir
# Inside def perform(%Oban.Job{args: %{"scenario_test_id" => id}}) do
HelloWeb.Endpoint.broadcast!(
  "scenario_report:#{scenario_test.scenario_report.id}",
  "update",
  %{
    scenario_test_id: id,
    status: :success
  }
)
```

## Where to subscribe the message? 

- Where to subscribe the message is important. It must be the same place where we subscribe.

- In `HelloWeb.ScenarioReportLive.Show`, during `mount` 

```elixir 
def mount(%{"id" => id}, _session, socket) do
  scenario_report =
    Scenarios.get_scenario_report!(id)
    |> Hello.Repo.preload(:scenario_tests)

  Logger.info("->> Subscribe to updates for scenario_report: #{scenario_report.id}")
  HelloWeb.Endpoint.subscribe("scenario_report:#{scenario_report.id}")

  {:ok, stream(socket, :scenario_tests, scenario_report.scenario_tests)}
end
```
Notice: we use `stream` to stream the `scenario_tests`.
Therefore, to use the `stream` with dedicated live component, we could 

```elixir 
<.live_component
  module={HelloWeb.ScenarioReportLive.ListScenarioTestsComponent}
  id="list-scenario-tests-in-report"
  streams={@streams}
/>
```

and inside `HelloWeb.ScenarioReportLive.ListScenarioTestsComponent`:

```elixir 
<.table id="scenario-tests" rows={@streams.scenario_tests}>
  <:col :let={{_id, scenario_test}} label="ID">{scenario_test.id}</:col>
  <:col :let={{_id, scenario_test}} label="Status">{scenario_test.status}</:col>
  <:action :let={{_id, scenario_test}}>
    <div class="sr-only">
      <.link navigate={~p"/scenario_tests/#{scenario_test}"}>Show</.link>
    </div>
  </:action>
</.table>
```


## Where to handle the subscribed message? 
- In the same `HelloWeb.ScenarioReportLive.Show`.

```elixir 
@impl true
def handle_info(
      %{
        topic: "scenario_report:" <> scenario_report_id,
        event: "update",
        payload: %{
          scenario_test_id: scenario_test_id,
          status: :success
        }
      },
      socket
    ) do
  Logger.info(
    "->> Received update for scenario_report: #{scenario_report_id}, scenario_test: #{scenario_test_id}"
  )

  scenario_test = Hello.Scenarios.get_scenario_test!(scenario_test_id)

  {:noreply,
   socket
   |> stream_insert(:scenario_tests, scenario_test)
   |> put_flash(
     :info,
     "Scenario test with id: #{scenario_test.id} is #{scenario_test.status}!"
   )}
end
```

Notice, this subscribe and receive message must be defined in `live_view`, not in other places. 
Because PubSub subscriptions are process-specific which is related with `live_view` which is a process.