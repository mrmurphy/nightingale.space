defmodule Nightingale.PageController do
  use Nightingale.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
