# How to schedule cluster to run scenario 

## Background

- User add multiple scenarios into a scenario group. 
  - Each item in scenario group is a scenario experiment which is `%{id: scenario_id, count: n}`.
- User run scenario group by runing each scenario test. 
  - A scenario report is created for it. 
  - A scenario test is created from `scenario_id` which is associated with `scenario_id` and `scenario_report_id`.
  - A scenario test need a dedicated AKS cluster to run.  
- The creation of A AKS cluster could be 30 mins.  

So, we need to allocate a pool of AKS clusters to run scenario tests. 

## Cluster Manager 

- `ClusterManager` is a `GenServer` which maintain a pool of AKS clusters. 
- When receive message: demand a cluster, it will try to find an available cluster from the pool.
  - If there is available cluster, it will return that `cluster_id`.
  - if there is no available cluster, it return 
    - `{:error, waiting_number}`

## Core components to run a scenario test 
- `ScenarioTestRunner` - abstract the running a scenario test. 
  - It could be a scenario test running from Aurora.
  - It could be a scenario test in our local system. 
  - Its status could be:
    - `ready`
    - `waiting for cluster`
    - `running`
    - `finished`
    - `failed`  
  
- `DynamicScenarioTestRunnerSupervior` - start a new scenario test runner process whenever the previous one finished / crashed. 
- `ScenarioTestLeader` - keep the copy of `ScenarioTestRunner` state outside of it, to keey track `ScenarioTestRunner`'s data. 
  - The responsibility of restarting `ScenarioTestRunner` will now be shifted to the `ScenarioTestLeader`.
  - It will keep track of `ScenarioTestRunner` status. 

So, a trio of services(Leader + DynamicRunnerSupervisor + Runner) for one scenario test. 

## `ScenarioTestSupervisor`
- For each scenario test, we will need above 3 services. So, to effectively initialize them, we use `ScenarioTestSupervisor-#{scenario-test-id}`.
- It will start both `ScenarioTestLeader` and `DynamicScenarioTestRunnerSupervior`.
- Since we need to create `ScenarioTestSupervisor-#{scenario-test-id}` dynamiclly on demand, we need to have another dynamic supervisor.
  - It will supervise `SceanrioTestSupervisor`.
  - It will be the direct children of application module.


## Schedule cluster on demand  
- When `ScenarioTestRunner` is ready, `ScenarioTestLeader` will call to `ClusterManager` to get an available cluster. 
  - If succeed, update `ScenarioTestRunner` status. 
  - If failed, 
    - It receive `{:error, waiting_number}`,
    - it subscribes to channel for listen AKS cluster update event. 
- When `ClusterManager` receive a call for available cluster: 
  - If there an available cluster, return the `cluster_id`.
  - If there is no available cluster 
    - return `{:error, waiting_number}`. 
    - use `Oban.Worker` to create a new AKS cluster, and notify `ClusterManager` when it ready. 
- When there are too many scenario tests waiting for cluster, `ClusterManager` will use queue to maintain the waiting order. 

## Improve Cluster Manager
Similar to scenario test runner, our `ClusterManager` should be reorginized as: 
- `ClusterRuntimeSupervisor` -- acts as the root supervisor for all cluster management components, not individual clusters.
- `DynamicClusterSupervior` -- supervise `ClusterRunner`
- `ClusterManager` -- keep track of all `ClusterRunner` state. 
- `ClusterRunner` -- process which represent a running cluster.  
  - `creating`
  - `available`
  - `busy`
  - `debug` 


## References 

- [Hands-on Elixir & OTP: Cryptocurrency trading bot](https://book.elixircryptobot.com/)