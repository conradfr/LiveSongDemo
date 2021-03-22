defmodule LiveSong.RadioServer do
  use GenServer, restart: :transient
  require Logger
  alias LiveSongWeb.Presence

  # 10s
  @refresh_radio_interval 10000
  # 15s
  @refresh_presence_interval 15000

  # ----- Client Interface -----

  @spec join(String.t(), String.t()) :: any()
  def join(radio_topic, radio_name) do
    case Registry.lookup(LiveSongRadioProviderRegistry, radio_topic) do
      [] ->
        DynamicSupervisor.start_child(
          LiveSong.RadioDynamicSupervisor,
          {__MODULE__, {radio_topic, radio_name}}
        )

      [{pid, _value}] ->
        GenServer.cast(pid, :broadcast)
    end
  end

  def start_link({radio_topic, radio_name} = _arg) do
    name = {:via, Registry, {LiveSongRadioProviderRegistry, radio_topic}}

    module_name =
      radio_name
      |> Macro.camelize()
      |> (&("Elixir.LiveSong.RadioProvider." <> &1)).()
      |> String.to_existing_atom()

    GenServer.start_link(__MODULE__, %{module: module_name, name: radio_topic, song: nil},
      name: name
    )
  end

  # ----- Server callbacks -----

  @impl true
  def init(state) do
    Logger.info("Radio provider - #{state.name}: starting ...")

    Process.send_after(self(), :refresh, 250)
    Process.send_after(self(), :presence, @refresh_presence_interval)
    {:ok, state}
  end

  @impl true
  def handle_cast(:broadcast, state) do
    LiveSongWeb.Endpoint.broadcast!(state.name, "playing", state.song)
    {:noreply, state}
  end

  @impl true
  def handle_info(:refresh, %{module: module, name: name} = state) do
    {_data, song} = get_data_song(module, name)

    LiveSongWeb.Endpoint.broadcast!(state.name, "playing", song)
    Process.send_after(self(), :refresh, @refresh_radio_interval)

    Logger.debug("#{inspect(song)}")
    Logger.info("Radio provider - #{name}: song updated (timer)")

    {:noreply, %{module: module, name: name, song: song}}
  end

  @impl true
  def handle_info(:presence, state) do
    how_many_connected =
      Presence.list(state.name)
      |> Kernel.map_size()

    case how_many_connected do
      0 ->
        Logger.info("Radio provider - #{state.name}: no client connected, exiting")
        {:stop, :normal, nil}

      _ ->
        Logger.debug("Radio provider - #{state.name}: #{how_many_connected} clients connected")

        Process.send_after(self(), :presence, @refresh_presence_interval)
        {:noreply, state}
    end
  end

  # ----- Internal -----

  @spec get_data_song(atom(), String.t()) :: tuple()
  defp get_data_song(module, name) do
    data = apply(module, :get_data, [name])
    song = apply(module, :get_song, [name, data]) || %{}

    {data, song}
  end
end
