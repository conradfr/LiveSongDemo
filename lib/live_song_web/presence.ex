defmodule LiveSongWeb.Presence do
  use Phoenix.Presence,
    otp_app: :live_song,
    pubsub_server: LiveSong.PubSub
end
