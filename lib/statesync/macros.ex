defmodule StateSync.Macros do
  defmacro defop(matchstr, do: expr) do
    expr = Macro.postwalk(expr, &postwalk/1)
    quote location: :keep do
      def do_op(unquote(matchstr), args, fullstate) do
        var!(args) = args
        var!(__fullstate) = fullstate
        origstate = get_in(fullstate, @path)
        var!(state) = origstate

        substate = unquote(Macro.postwalk(expr, &postwalk/1))

        case origstate do
          nil -> Prelude.Map.deep_put(var!(__fullstate), @path, substate)
          _ -> put_in(var!(__fullstate), @path, substate)
        end
      end

    end
  end

  def postwalk({:emit, _, [op, arg]}) do
    quote do
      var!(__fullstate) = do_op(unquote(op), unquote(arg), var!(__fullstate))
    end
  end

  def postwalk(ast) do
    ast
  end
end

