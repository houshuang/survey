defmodule Survey.ReflectionController do
  use Survey.Web, :controller

  require Logger
  alias Survey.Prompt
  import Prelude
  alias Survey.Repo
  alias Survey.Prompt

  plug :action

  def index(conn, params) do
    prompt = Repo.get(Prompt, params["id"])
    render conn, "index.html", html: prompt.html
  end
end
