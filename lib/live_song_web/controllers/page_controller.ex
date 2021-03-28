defmodule LiveSongWeb.PageController do
  use LiveSongWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def player(conn, _params) do
    render(conn, "player.html", layout: {LiveSongWeb.LayoutView, "player.html"})
  end
end
