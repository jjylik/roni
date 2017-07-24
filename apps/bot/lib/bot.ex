defmodule RoniBot do

  require Logger

  def start(_type, _args) do
    Logger.debug "Starting HTTPoison..."
    HTTPoison.start

    Logger.debug "Starting bot..."
    RoniBot.Supervisor.start
  end


end