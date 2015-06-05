defmodule Survey.Router do
  use Survey.Web, :router

  pipeline :initial do
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug EnsureRegistered
  end

  pipeline :register do
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug EnsureRegistered
  end

  scope "/", Survey do
    pipe_through :initial
    post "/tags", TagController, :index
    get "/tags", TagController, :index
  end

  scope "/", Survey do
    pipe_through :browser

    get "/", PageController, :index
    post "/tags/submit", TagController, :submit
    post "/tags/submitajax", TagController, :submitajax

  end

  scope "/", Survey do
    pipe_through :register
    get "/register", UserController, :index
    post "/register/submit", UserController, :submit
  end
end
