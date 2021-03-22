defmodule LiveSong.RadioProvider do
  @doc """
    Get source data as map
  """
  @callback get_data(String.t()) :: map() | nil

  @doc """
    Get artist & song as map %{artist: nil, title: nil}
  """
  @callback get_song(String.t(), map() | nil) :: map()
end
