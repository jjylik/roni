defmodule Images.Reader do
  
  def get_one(directory, filter) do
    {:ok, files} = File.ls(directory)
    files = Enum.reject(files, &(Enum.member?(filter, &1) || !String.contains?(:mimerl.filename(&1), "image")))
    filename = Enum.random(files)
    directory <> "/" <> filename
  end

end