defmodule GithubPagesConnector.TransactionalPipeline do
  @moduledoc """

  The `TransactionalPipeline` module allows you to run a series of functions
  on the same set of arguments, making sure that either all or none of those
  functions succeed.

  In order for the pipeline to work, all the functions that are part of the
  pipeline must follow a set of conventions:

  - Have the same arity and receive the same parameters. Even if a function
    only cares about one of the params, it must accept (and return) all of
    them.
  - Use the following return values:

    1. When the function succeeds, it must return a tuple like:

      ```
      {:ok, [arg1, arg2, ..., argN], [revert_fn1, revert_fn2, ..., revert_fnN]}`
      ```

      The first list contains the arguments will be the input of the next
      function in the pipeline. These arguments may or may not have the same
      values than the ones the function got.

      The second list contains a series of anonymous functions that will revert
      any side-effects the executed function caused. These functions will be run
      in case any step of the pipeline failed to rollback all changes.

      Note that the functions should be closures holding any data they need to
      run as they should expect no arguments.

      If the function caused no side effects this list should be empty:

      ```
      {:ok, [arg1, arg2, ..., argN], []}`
      ```

    2. When the function fails, it must return a tuple like:

      ```
      {:error, "Error message"}
      ```

  Here is a simple example with anonymous functions that cause no side effects
  to illustrate how the pipeline works:

  ```
  add_two = fn(a, b) -> {:ok, [a+2, b+2], []} end
  squares = fn(a, b) -> {:ok, [a*a, b*b], []} end

  TransactionalPipeline.run([add_two, squares], [1, 2])
  #=> {:ok, [9, 16]}

  TransactionalPipeline.run([squares, add_two], [1, 2])
  #=> {:ok, [3, 6]}
  ```

  """
  @spec run(List.t, List.t) :: {:ok, List.t} | {:error, String.t}
  def run(functions, args) do
    do_run(functions, args, [])
  end

  defp do_run([], args, _rollback_functions), do: {:ok, args}
  defp do_run([h | t], args, rollback) do
    case run_step(h, args) do
      {:ok, new_args, step_rollback} ->
        do_run(t, new_args, step_rollback ++ rollback)
      {:error, details} ->
        revert(rollback)
        {:error, details}
    end
  end

  def run_step(function, args) do
    try do
      apply(function, args)
    catch
      error, details -> {:error, {error, details}}
    end
  end

  def revert(rollback) do
    Enum.each(rollback, &(&1.()))
  end

end
