defmodule TheRushWeb.PageLiveTest do
  use TheRushWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "the Rush"
    assert render(page_live) =~ "NFL Rushing Stat"
  end
end
