defmodule TheRushWeb.CsvController do
  use TheRushWeb, :controller

  def export(conn, %{"socket_id" => socket_id}) do
    case get_rushing_stats(socket_id) do
      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
      {:ok, csv_content} ->
        csv =
          csv_content
          |> CSV.encode(headers: get_cols())
          |> Enum.to_list()
          |> to_string()

        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"theScore NFL rushing stat nfl_rushing_stat.csv\"")
        |> send_resp(200, csv)
    end
  end

  defp get_rushing_stats(token_id) do
    case ConCache.get(:csv, String.to_atom(token_id)) do
      nil ->
        {:error, "csv_content doesn't exist or has expired"}
      csv_content ->
        {:ok, csv_content}
    end
  end

  defp get_cols() do
    case ConCache.get(:csv, :cols) do
      nil -> ["Player", "Team","Pos", "Att/G", "Att", "Yds", "Avg", "Yds/G", "TD", "Lng", "1st", "1st%", "20+", "40+", "FUM"]
      cols -> cols
    end
  end
end
