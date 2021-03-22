defmodule LiveSongWeb.Router do
  use LiveSongWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveSongWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/player", PageController, :player
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveSongWeb do
  #   pipe_through :api
  # end
end
