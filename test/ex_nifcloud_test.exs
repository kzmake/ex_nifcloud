defmodule ExNifcloudTest do
  use ExUnit.Case
  #doctest ExNifcloud

  test "request" do
    assert ExNifcloud.hello() == :world
  end
end
