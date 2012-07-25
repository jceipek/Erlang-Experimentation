defmodule Rev do
  def reverse(list) do
    reverse list, []
  end

  def reverse([], list) do
    list
  end

  def reverse([head | rest], sorted) do
    reverse rest, [head | sorted]
  end
end
