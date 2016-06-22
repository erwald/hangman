defmodule Hangman.PageController do
  use Hangman.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
