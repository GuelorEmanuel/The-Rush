defmodule TheRushWeb.PageLive do
  use TheRushWeb, :live_view
  alias TheRush.RushingStatsFromMongo

  @impl true
  def mount(_params, _session, socket) do
    limit = 20
    rows = RushingStatsFromMongo.sort_by(:Yds, -1, :Yds)
    len_of_rows = Enum.count(rows)

    cols = RushingStatsFromMongo.get_cols()
    rows_to_show = get_rows_to_show(limit, rows)

    show_load_more =
      len_of_rows
      |> show_more?(rows_to_show)

    # cache cols
    one_day_in_seconds = 86400
    ConCache.put(:csv,
                 :cols,
                 %ConCache.Item{value: cols, ttl: one_day_in_seconds})
    socket
    |> cache_rows_to_show(rows_to_show)

    {:ok, assign(socket, rows: rows, cols: cols, query: "", sort_state: :Yds,
                 limit: limit, rows_to_show: rows_to_show, show_load_more: show_load_more)}
  end

  @impl true
  def handle_event("load-more", _session, socket) do
    limit = socket.assigns.limit + 20
    sort_state = socket.assigns.sort_state

    rows =
       sort_state
      |> RushingStatsFromMongo.sort_by(-1, sort_state)

    rows_to_show = get_rows_to_show(limit, rows)
    show_load_more =
      Enum.count(rows)
      |> show_more?(rows_to_show)

    socket
    |> cache_rows_to_show(rows_to_show)

    {:noreply, assign(socket, rows: rows, limit: limit, rows_to_show: rows_to_show, show_load_more: show_load_more)}
  end

  @impl true
  def handle_event("sort", %{"_target" => params}, socket) do
    current_target =
      params
      |> get_current_target()

    limit = socket.assigns.limit
    query = socket.assigns.query

    rows =
      current_target
      |> RushingStatsFromMongo.sort_by(-1, current_target)

    rows_to_show_filtered =
      query
      |> apply_player_filter(rows)

    rows_to_show =
      limit
      |> get_rows_to_show(rows_to_show_filtered)

    socket
    |> cache_rows_to_show(rows_to_show)

    {:noreply, assign(socket, rows: rows, sort_state: current_target, rows_to_show: rows_to_show)}
  end

  @impl true
  def handle_event("filter", %{"q" => query}, socket) do
    rows = socket.assigns.rows

    rows_to_show =
      query
      |> apply_player_filter(rows)

    socket
    |> cache_rows_to_show(rows_to_show)

    {:noreply, assign(socket, rows_to_show: rows_to_show, query: query)}
  end

  defp cache_rows_to_show(%{id: id}, rows_to_show) do
    five_hours_in_secods = 1_8000
    ConCache.put(:csv,
                 String.to_atom(id),
                 %ConCache.Item{value: rows_to_show, ttl: five_hours_in_secods})
  end

  defp apply_player_filter(query, rows) do
    case String.trim(query) == "" do
      true -> rows
      _ ->
        query
        |> string_to_list(rows)
        |> filter_by_player(rows, "Player")
    end
  end

  defp string_to_list(query, rows) when query == "", do: rows
  defp string_to_list(query, _rows) do
    query
    |> String.split(",")
    |> Enum.map(&String.downcase(&1))
  end

  defp get_current_target([head | _tail] = target) when length(target) == 1 do
    case head do
      "_csrf_token" -> :Yds
      _ -> head
    end
  end
  defp get_current_target(target) do
    target
    |> List.last()
    |> String.to_atom()
  end

  defp show_more?(len_of_rows, rows_to_show) do
    len_of_rows != Enum.count(rows_to_show)
  end

  defp get_rows_to_show(limit, rows), do: Enum.take(rows, limit)

  defp filter_by_player([], _rows, _key), do: []
  defp filter_by_player(queries, rows, key) do
    rows
    |> Enum.filter(fn row -> is_member?(queries, row[key]) end)
  end

  defp is_member?(queries, player) do
    temp_player =
      player
      |> String.downcase()
    case Enum.find(queries, &(trim_string(&1) == temp_player or is_substring_or_is_equal(&1,temp_player))) do
      nil -> false
      _ -> true
    end
  end

  defp is_substring_or_is_equal(query, temp_player) do
    case String.trim(query) == "" do
      true -> false
      _ -> temp_player=~ trim_string(query)
    end
  end

  defp trim_string(str) do
    str
    |> String.trim_leading()
    |> String.trim_trailing(" ")
  end
end
