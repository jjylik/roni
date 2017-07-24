defmodule ConsumerTest do
  use ExUnit.Case, async: false
  alias Nostrum.Struct.Message
  alias RoniBot.Consumer
  alias Nostrum.Api
  import Mock

  test "Send !roni message should trigger api call" do
    with_mock Api, [create_message: fn(_channel, _msg, _tts) -> :ok end] do
      last_command_time = :os.system_time(:seconds) - 11
      {:ok, state} = Consumer.handle_event({:MESSAGE_CREATE, {%Message{channel_id: 1, content: "!roni"}}, []},
        %{:last_command => last_command_time, :previous_images => []})
      assert Enum.count(state[:previous_images]) == 1
      assert state[:last_command] > last_command_time
      assert called Api.create_message(1, :_, false)
    end
  end

  test "Send !roni message should not trigger api call if called within throttle period" do
    with_mock Api, [create_message: fn(_channel, _msg, _tts) -> :ok end] do
      {:ok, state} = Consumer.handle_event({:MESSAGE_CREATE, {%Message{channel_id: 1, content: "!roni"}}, []},
        %{:last_command => :os.system_time(:seconds), :previous_images => []})
      assert Enum.count(state[:previous_images]) == 0
      assert !called Api.create_message(1, :_, false)
    end
  end


end
