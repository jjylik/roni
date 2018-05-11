defmodule Images.ReaderTest do
  alias Images.Reader
  use ExUnit.Case

  test "Reader should filter images" do
    filename = Reader.get_one("test/test_images", ["gray.png"])
    assert filename == "test/test_images/white.png"
  end

end