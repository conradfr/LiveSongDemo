defmodule LiveSong.RadioProvider.Fip do
  require Logger

  @behaviour LiveSong.RadioProvider

  @radio_endpoint "https://api.radiofrance.fr/livemeta/live/7/webrf_fip_player"

  @impl true
  def get_data(name) do
    Logger.debug("Radio provider - #{name}: querying...")

    try do
      data =
        @radio_endpoint
        |> HTTPoison.get!()
        |> Map.get(:body)
        |> Jason.decode!()

      now_unix = DateTime.utc_now() |> DateTime.to_unix()

      if data != nil and Map.get(data, "now") != nil
         and Map.get(data["now"], "startTime") != nil and Map.get(data["now"], "endTime") != nil
         and now_unix >= data["now"]["startTime"] and now_unix <= data["now"]["endTime"] do
        data
      else
        nil
      end
    rescue
      _ -> nil
    end
  end

  @impl true
  def get_song(name, data) do
    case data do
      nil ->
        Logger.warn("Radio provider - #{name}: error fetching song data or empty")
        %{}

      _ ->
        Logger.debug("Radio provider - #{name}: querying OK")
        %{artist: Map.get(data["now"], "secondLine"), title: Map.get(data["now"], "firstLine")}
    end
  end
end
