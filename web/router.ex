defmodule Survey.Router do
  use Survey.Web, :router

  pipeline :browser do
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug EnsureRegistered
  end

  # don't ensure registered, only for new users to register
  pipeline :register do
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  scope "/", Survey do
    pipe_through :browser
    post "/tags", TagController, :index
    get "/tags", TagController, :index
    get "/", PageController, :index
    post "/tags/submit", TagController, :submit
    post "/tags/submitajax", TagController, :submitajax
    get "/userinfo", UserController, :info
  end

  scope "/", Survey do
    pipe_through :register
    get "/register", UserController, :index
    post "/register/submit", UserController, :submit
  end
end
