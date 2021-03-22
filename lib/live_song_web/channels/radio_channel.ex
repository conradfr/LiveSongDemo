defmodule LiveSongWeb.RadioChannel do
  use Phoenix.Channel
  alias LiveSongWeb.Presence
  alias LiveSong.RadioServer

  def join("radio:" <> radio_name, _params, socket) do
    send(self(), {:after_join, "radio:" <> radio_name, radio_name})
    {:ok, socket}
  end

  def handle_info({:after_join, radio_topic, radio_name}, socket) do
    {:ok, _} =
      Presence.track(self(), radio_topic, :rand.uniform(), %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(radio_topic))
    RadioServer.join(radio_topic, radio_name)
    {:noreply, socket}
  end
end
