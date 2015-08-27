defmodule StateSync do

  defmacro __using__(ops) do
    quote do
      import StateSync.Macros
      require StateSync.Macros
    end
  end

end

