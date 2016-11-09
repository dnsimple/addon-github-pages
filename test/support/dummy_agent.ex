defmodule DummyAgent do

  defmacro __using__(_opts) do
    quote do
      def start_link do
        Agent.start_link(fn -> Map.new end, name: __MODULE__)
      end

      def stub(function, return_value) do
        Agent.update(__MODULE__, &Map.put(&1, function, return_value))
      end

      def calls do
        Agent.get(__MODULE__, &Map.get_lazy(&1, :calls, fn -> [] end))
      end

      def reset do
        Agent.update(__MODULE__, fn(_) -> Map.new end)
      end


      defp get_stubbed_value(function, default) do
        Agent.get(__MODULE__, &Map.get_lazy(&1, function, fn -> default end))
      end

      defp record_call(function, args) do
        Agent.update(__MODULE__, &Map.update(&1, :calls, [], fn(calls) -> calls ++ [{function, args}] end))
      end
    end
  end

end
