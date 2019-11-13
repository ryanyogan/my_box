defmodule MyBoxWeb.PageController do
  use MyBoxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
