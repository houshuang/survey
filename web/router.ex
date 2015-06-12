defmodule Survey.Router do
  use Survey.Web, :router

  pipeline :browser do
    plug ParamSession
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_flash
    plug EnsureRegistered
  end

  # don't ensure registered, only for new users to register
  pipeline :register do
    plug ParamSession
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_flash
  end

  scope "/", Survey do
    pipe_through :browser
    get "/survey", SurveyController, :index
    post "/survey", SurveyController, :index
    post "/survey/submit", SurveyController, :submit
    post "/survey/submitajax", SurveyController, :submitajax

    get "/user/info", UserController, :info
    post "/user/info", UserController, :info
    post "/user/delete_user", UserController, :delete_user
    post "/user/delete_survey", UserController, :delete_survey
  end

  scope "/", Survey do
    pipe_through :register
    get "/user/register", UserController, :index
    post "/user/register/submit", UserController, :submit
    post "/user/get_tags", UserController, :get_tags
  end
end
