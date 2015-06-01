defmodule Survey.Router do
  use Survey.Web, :router

  pipeline :initial do
    plug PlugLti
    plug :accepts, ["html"]
  end

  end
  pipeline :browser do
    plug PlugLti
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Survey do
    pipe_through :initial
    post "/tags", TagController, :index
  end

  scope "/", Survey do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/tags/submit", TagController, :submit
   resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Survey do
  #   pipe_through :api
  # end
end
