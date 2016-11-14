defmodule GithubPagesConnector.TransactionalPipelineTest do
  use ExUnit.Case, async: true

  alias GithubPagesConnector.TransactionalPipeline

  test "it runs an anonymous function" do
    square = fn(a, b) -> {:ok, [a*a, b*b], []} end
    assert TransactionalPipeline.run([square], [1, 5]) == {:ok, [1, 25]}
  end

  def add2(a, b), do: {:ok, [a+2, b+2], []}
  def add3(a, b), do: {:ok, [a+3, b+3], []}

  test "it runs a named function" do
    assert TransactionalPipeline.run([&__MODULE__.add3/2], [2, 4]) == {:ok, [5, 7]}
  end

  test "it chains functions together" do
    assert TransactionalPipeline.run([&add2/2, &add3/2], [1, 1]) == {:ok, [6, 6]}
  end

  def error(_a, _b), do: {:error, "A failure"}

  test "it stops the pipeline if a function returns an error" do
    assert TransactionalPipeline.run([&add2/2, &add3/2, &error/2], [0, 0]) == {:error, "A failure"}
  end

  defmodule TestAgent do
    def add_random do
      current_value = get
      update(get + :rand.uniform(100))
      {:ok, [], [fn -> update(current_value) end]}
    end

    def error do
      {:error, "error details"}
    end

    def raise_error do
      raise "error"
    end

    def start_link(initial_value \\ 0) do
      Agent.start_link(fn -> initial_value end, name: __MODULE__)
    end

    def get do
      Agent.get(__MODULE__, &(&1))
    end

    def update(new_value) do
      Agent.update(__MODULE__, fn(_) -> new_value end)
    end

    def stop do
      Agent.stop(__MODULE__)
    end
  end

  test "works with side effects" do
    TestAgent.start_link(-2)
    assert TestAgent.get == -2
    TransactionalPipeline.run([&TestAgent.add_random/0], [])
    refute TestAgent.get == -2
    TestAgent.stop
  end

  test "rollbacks in case of error" do
    TestAgent.start_link(-1)
    assert TransactionalPipeline.run([&TestAgent.add_random/0, &TestAgent.error/0], []) == {:error, "error details"}
    assert TestAgent.get == -1
    TestAgent.stop
  end

  test "rollbacks in case of exception" do
    TestAgent.start_link(-1)
    assert TransactionalPipeline.run([&TestAgent.add_random/0, &TestAgent.raise_error/0], []) == {:error, {:error, %RuntimeError{message: "error"}}}
    assert TestAgent.get == -1
    TestAgent.stop
  end

  @tag :skip
  test "rollback operations are applied in reverse order" do
  end

  @tag :skip
  test "pipelines can be composition of other pipelines" do
  end

end
