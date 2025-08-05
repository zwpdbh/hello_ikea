defmodule Hello.Venomous.PlayTest do
  use Hello.DataCase
  alias Venomous.SnakeArgs
  import Venomous

  test "case01" do
    timeout = 1_000
    args = SnakeArgs.from_params(:builtins, :sum, [[0, 1, 2, 3, 4, 5]])

    case python(args, python_timeout: timeout) do
      {:retrieve_error, msg} -> "No Snakes? #{inspect(msg)}"
      %{error: :timeout} -> "We timed out..."
      sum -> assert sum == 15
    end

    # or just use python!/3 which waits for the available snake.
    timeout = :infinity
    assert python!(args, python_timeout: timeout) == 15
  end

  test "case02" do
    # Venomous can handle as much concurrent python as you've setup
    # in your snake_manager configuration. However the python! will
    # wait for any process to free up in case none are available.
    args = SnakeArgs.from_params(:time, :sleep, [0.5])

    Enum.map(1..100, fn _ ->
      Task.async(fn ->
        python!(args)
      end)
    end)
    |> Task.await_many(5_000)

    # You can view the spawned and ready snakes using the list_alive_snakes()
    list_alive_snakes() |> dbg
  end

  test "case03" do
    # Venomous kills the OS pid of the python process on :EXIT
    # ensuring the process will not proceed with the execution further
    Enum.map(1..200, fn _ ->
      {:ok, pid} =
        Task.start(fn ->
          SnakeArgs.from_params(:time, :sleep, [1000]) |> python!()
        end)

      pid
    end)
    |> Enum.each(fn pid ->
      Process.send_after(pid, {:EXIT, :snake_slithered_away}, 100)
    end)

    # We'll sleep to make sure all exits got sent.
    Process.sleep(1_000)
    assert list_alive_snakes() == []
  end
end
