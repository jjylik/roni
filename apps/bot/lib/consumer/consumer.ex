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

  @throttle_limit 10
  @image_history_size 2
 
  def start_link do
    Consumer.start_link(__MODULE__, %{:last_command => :os.system_time(:seconds), :previous_images => []})
  end

  def handle_event({:MESSAGE_CREATE, {msg}, ws_state}, state) do
    state = cond do
      throttle_limit?(state) -> state
      msg.content == "!roni" -> post_random_image(msg.channel_id, state)
      true -> state
    end
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  defp throttle_limit?(state) do
    (:os.system_time(:seconds) - state[:last_command]) < @throttle_limit
  end

  defp post_random_image(channel_id, state) do
    directory = Application.get_env(:bot, :images_directory)
    previous_images = state[:previous_images]
    {filename, binary} = Reader.get_one(directory, previous_images)
    Api.create_message(channel_id, [file_name: filename, file: binary], false)
    state
      |> Map.put(:previous_images, add_to_previous_images(previous_images, filename))
      |> Map.put(:last_command, :os.system_time(:seconds))
  end

  defp add_to_previous_images(previous_images, filename) do
    [filename | previous_images]
      |> Enum.slice(0, @image_history_size)
  end

end