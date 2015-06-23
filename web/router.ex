defmodule Survey.Router do
  use Survey.Web, :router

  pipeline :browser do
    plug ParamSession
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_flash
    plug EnsureRegistered
    plug EnsureSIG
  end

  # don't ensure registered, only for new users to register
  pipeline :register do
    plug ParamSession
    plug EnsureLti
    plug :accepts, ["html"]
    plug :fetch_flash
  end

  pipeline :admin do
    plug Plug.Session,
      store: :cookie,
      key: "_test_key",
      signing_salt: "LMvTyOc2"
    plug :fetch_session
    plug VerifyAdmin
    plug :fetch_flash
    plug :accepts, ["html"]
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
    post "/gradecheck", UserController, :gradecheck
    post "/gradecheck_submit", UserController, :gradecheck_submit
  end

  scope "/", Survey do
    pipe_through :register
    get "/user/register", UserController, :index
    post "/user/register/submit", UserController, :submit
    post "/user/get_tags", UserController, :get_tags
    get "/user/select_sig", UserController, :select_sig
    post "/user/select_sig/submit", UserController, :select_sig_submit
  end

  scope "/admin", Survey do
    pipe_through :admin
    get "/report", ReportController, :index
    get "/report/text/:qid", ReportController, :textanswer
    get "/report/tags", ReportController, :tags
    get "/gradecheck", UserController, :gradecheck
  end
end
