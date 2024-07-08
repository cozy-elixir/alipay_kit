defmodule AlipayKitTest do
  use ExUnit.Case
  doctest AlipayKit

  test "greets the world" do
    assert AlipayKit.hello() == :world
  end
end
