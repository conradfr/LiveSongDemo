defmodule LiveSong.RadioProvider.Fip do
  require Logger

  @behaviour LiveSong.RadioProvider

  @radio_endpoint "https://www.fip.fr/latest/api/graphql?operationName=NowList&variables={\"bannerPreset\":\"266x266\",\"stationIds\":[7]}&extensions={\"persistedQuery\":{\"version\":1,\"sha256Hash\":\"151ca055b816d28507dae07f9c036c02031ed54e18defc3d16feee2551e9a731\"}}"

  @impl true
  def get_data(name) do
    Logger.debug("Radio provider - #{name}: querying...")

    try do
      @radio_endpoint
      |> HTTPoison.get!()
      |> Map.get(:body)
      |> Jason.decode!()
      |> Map.get("data", %{})
      |> Map.get("nowList", %{})
      |> List.first()
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
        %{artist: data["playing_item"]["title"], title: data["playing_item"]["subtitle"]}
    end
  end
end
