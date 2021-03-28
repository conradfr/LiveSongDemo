defmodule LiveSongWeb.LogsChannel do
  use Phoenix.Channel

  def join("logs:all", _params, socket) do
    {:ok, socket}
  end
end
