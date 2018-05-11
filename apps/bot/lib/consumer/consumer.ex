defmodule RoniBot.Supervisor do
  def start do
    import Supervisor.Spec

    children = [worker(RoniBot.Consumer, [])]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule RoniBot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api
  alias Images.Reader
  require Logger
  import Nostrum.Struct.Embed

  @throttle_limit 10
  @image_history_size 2
 
  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do

    cond do
      msg.content == "!ping" -> Api.create_message(msg.channel_id, content: "pong!")
      msg.content == "!roni" -> post_random_image(msg.channel_id)
      msg.content == "!help" -> Api.create_message(msg.channel_id, content: "Commands: !roni")
      true -> :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end

  defp post_random_image(channel_id) do
    embed =
    %Nostrum.Struct.Embed{}
    |> put_title("heloust")
    directory = Application.get_env(:bot, :images_directory)
    previous_images = []
    filename = Reader.get_one(directory, previous_images)
    Api.create_message(channel_id, file: filename, embed: embed)
  end

end