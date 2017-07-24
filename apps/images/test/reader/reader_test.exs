defmodule Images.ReaderTest do
  alias Images.Reader
  use ExUnit.Case

  test "Reader should find images" do
    {_, _} = Reader.get_one("test/test_images", [])
  end

  test "Reader should filter images" do
    {filename, _} = Reader.get_one("test/test_images", ["gray.png"])
    assert filename == "white.png"
  end

end