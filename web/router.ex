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

    # survey
    get "/survey", SurveyController, :index
    post "/survey", SurveyController, :index
    post "/survey/submit", SurveyController, :submit
    post "/survey/submitajax", SurveyController, :submitajax

    # user info/debug
    get "/user/info", UserController, :info
    post "/user/info", UserController, :info
    post "/user/delete_user", UserController, :delete_user
    post "/user/delete_survey", UserController, :delete_survey

    # resource submission/review
    post "/resource/add", ResourceController, :add
    get "/resource/add", ResourceController, :add

    post "/resource/review", ResourceController, :review
    post "/resource/review/submit", ResourceController, :review_submit
    get "/resource/review", ResourceController, :review
    post "/resource/review/:id", ResourceController, :review
    get "/resource/review/:id", ResourceController, :review
    post "/resource/check_url", ResourceController, :check_url
  
    get "/user/select_sig_freestanding", UserController, :select_sig
    post "/user/select_sig_freestanding", UserController, :select_sig
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
    get "/report/resource", ResourceController, :report
    get "/resource/preview", ResourceController, :preview
  end
end
