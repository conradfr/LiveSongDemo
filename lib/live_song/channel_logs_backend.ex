defmodule LiveSong.ChannelLogsBackend do
  @behaviour :gen_event

  require Logger

  alias Logger.Formatter

  defstruct [
    :format,
    :level,
    :metadata,
    :utc_log
  ]

  @default_conf [
    format: "$time [$level] $message",
    metadata: []
  ]

  @impl true
  def init(__MODULE__) do
    config = Keyword.merge(default_conf(), Application.get_env(:logger, __MODULE__, []))
    init({__MODULE__, config})
  end

  def init({__MODULE__, options}) do
    {:ok, config(options, %__MODULE__{})}
  end

  defp config(options, state) do
    config = Keyword.merge(Application.get_env(:logger, __MODULE__, []), options)

    Application.put_env(:logger, __MODULE__, config)

    state = %__MODULE__{
      state
      | format: Formatter.compile(Keyword.get(config, :format)),
        level: Keyword.get(config, :level),
        metadata: Keyword.get(config, :metadata),
        utc_log: Keyword.get(config, :utc_log)
    }

    state
  end

  @impl true
  def handle_call({:configure, options}, state) do
    {:ok, :ok, config(options, state)}
  end

  def handle_call(_, state) do
    {:ok, :ok, state}
  end

  @impl true
  def handle_event(
        {level, group_leader, {Logger, message, timestamp, metadata}} = event,
        state
      ) do
    if meet_level?(level, state.level) and node(group_leader) == node() do
      message_formatted =
        state.format
        |> Formatter.format(level, message, timestamp, metadata)
        |> List.to_string()

      LiveSongWeb.Endpoint.broadcast!("logs:all", "log", %{message: message_formatted})
      event
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  @impl true
  def handle_info({__MODULE__, msg}, state) do
    handle_info(msg, state)
  end

  def handle_info(_msg, state) do
    {:ok, state}
  end

  @impl true
  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  @impl true
  def terminate(:swap, state) do
    [
      format: state.format,
      level: state.level,
      metadata: state.metadata
    ]
  end

  @compile {:inline, meet_level?: 2}
  @doc false
  def meet_level?(_lvl, nil), do: true

  def meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp default_conf do
    @default_conf
    |> Keyword.put(:utc_log, Application.get_env(:logger, :utc_log, false))
  end
end
