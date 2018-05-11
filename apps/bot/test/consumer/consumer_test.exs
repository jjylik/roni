defmodule ConsumerTest do
  use ExUnit.Case, async: false
  alias Nostrum.Struct.Message
  alias RoniBot.Consumer
  alias Nostrum.Api
  import Mock

  test "Send !roni message should trigger api call" do
    with_mock Api, [create_message: fn(_channel, _msg) -> :ok end] do
      last_command_time = :os.system_time(:seconds) - 11
      res = Consumer.handle_event({:MESSAGE_CREATE, {%Message{channel_id: 1, content: "!roni"}}, %{}})
      assert called Api.create_message(1, :_, false)
    end
  end


end
