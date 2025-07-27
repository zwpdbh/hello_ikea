# How to handle cascade deletion 


## Before 

```elixir 
defmodule Hello.Scenarios.ScenarioReport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scenario_reports" do
    field :name, :string
    field :status, Ecto.Enum, values: [:scheduled, :running, :completed, :failed]
    field :scheduled_time, :utc_datetime

    belongs_to :scenario_group, Hello.Scenarios.ScenarioGroup
    has_many :scenario_tests, Hello.Scenarios.ScenarioTest

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scenario_report, attrs) do
    scenario_report
    |> cast(attrs, [:name, :scheduled_time, :status, :scenario_group_id])
    |> validate_required([:name, :scheduled_time, :status, :scenario_group_id])
    |> foreign_key_constraint(:scenario_group_id)
  end
end
```

When delete a scenario report, the log shows error:

```txt 
[debug] QUERY ERROR source="scenario_reports" db=0.8ms queue=0.6ms idle=1254.9ms
DELETE FROM "scenario_reports" WHERE "id" = $1 [1]
↳ HelloWeb.ScenarioReportLive.Index.handle_event/3, at: lib/hello_web/live/scenario_report_live/index.ex:48
[error] GenServer #PID<0.16457.0> terminating
** (Ecto.ConstraintError) constraint error when attempting to delete struct:

    * "scenario_tests_scenario_report_id_fkey" (foreign_key_constraint)

If you would like to stop this constraint violation from raising an
exception and instead add it as an error to your changeset, please
call `foreign_key_constraint/3` on your changeset with the constraint
`:name` as an option.

The changeset has not defined any constraint.

    (ecto 3.12.5) lib/ecto/repo/schema.ex:881: anonymous fn/4 in Ecto.Repo.Schema.constraints_to_errors/3
    (elixir 1.18.1) lib/enum.ex:1714: Enum."-map/2-lists^map/1-1-"/2
    (ecto 3.12.5) lib/ecto/repo/schema.ex:865: Ecto.Repo.Schema.constraints_to_errors/3,
```

- The error occurs because you're trying to delete a `ScenarioReport` that still has associated `ScenarioTest records`. 
- The database foreign key constraint `scenario_tests_scenario_report_id_fkey` prevents deleting parent records `scenario_reports` while child records `scenario_tests` still reference them.


## Solution:

```elixir 
# Modify Hello.Scenarios.ScenarioReport to add "on_delete: :delete_all"
has_many :scenario_tests, Hello.Scenarios.ScenarioTest, on_delete: :delete_all
```