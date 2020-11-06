defmodule TheRush.RushingStatsFromMongo do
  @moduledoc """
  Retrieve the stats information from mongodb
  """
  def to_csv(map, path) do
    file = File.open!(path, [:write, :utf8])

    map
    |> IO.inspect()
    |> CSV.encode(headers: true)
    |> Enum.each(&IO.write(file, &1))
  end

  def get_rows() do
    :mongo
    |> Mongo.find("rushing_stats", %{})
    |> Enum.map(fn rush_stat -> Map.delete(rush_stat, "_id") end)
  end

  def get_cols() do
    :mongo
    |> Mongo.find_one("rushing_stats", %{})
    |> Map.delete("_id")
    |> Map.keys()
  end

  def sort_by(atom_key, value, :TD) do
    column_to_sort_by =
      %{}
      |> Map.put(atom_key, value)

    :mongo
    |> Mongo.find("rushing_stats", %{}, sort: column_to_sort_by)
    |> Enum.map(fn rush_stat -> Map.delete(rush_stat, "_id") end)
  end
  def sort_by(atom_key, _value, _any) do
    get_rows()
    |> Enum.sort_by(&(handle_conversion(&1[Atom.to_string(atom_key)])), :desc)
  end

  defp handle_conversion(value) when is_integer(value), do: value
  defp handle_conversion(value) when is_binary(value) do
    case String.contains?(value, "T") do
      true ->
        value
        |> String.slice(0..-2)
        |> String.to_integer()
      _ ->
        value
        |> String.replace(",", "")
        |> String.to_integer()
    end

  end


end
