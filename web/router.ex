defmodule Survey.Router do
  use Survey.Web, :router
  @logformat "%u %t %m \"%U\" %>s %b %D"

  socket "/ws", Survey do
    channel "rooms:*", RoomChannel
    channel "admin", AdminChannel
  end

  pipeline :browser do
    plug ParamSession
    plug EnsureLti
    plug Plug.AccessLog,
      format: @logformat,
      file: "log/access_log"
    plug :accepts, ["html"]
    plug :fetch_flash
    plug EnsureRegistered
    plug EnsureSIG
  end

  # don't ensure registered, only for new users to register
  pipeline :register do
    plug ParamSession
    plug EnsureLti
    plug Plug.AccessLog,
      format: @logformat,
      file: "log/access_log"
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
    plug Plug.AccessLog,
      format: @logformat,
      file: "log/access_log"
    plug :fetch_flash
    plug :accepts, ["html"]
  end

  pipeline :public do
    plug Plug.Session,
      store: :cookie,
      key: "_test_key",
      signing_salt: "LMvTyOc2"
    plug :fetch_session
    plug Plug.AccessLog,
      format: @logformat,
      file: "log/access_log"
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

    # resource submission/review
    post "/resource/add", ResourceController, :add
    get "/resource/add", ResourceController, :add

    post "/resource/review", ResourceController, :review
    post "/resource/review/submit", ResourceController, :review_submit
    get "/resource/review", ResourceController, :review
    post "/resource/review/:id", ResourceController, :review
    get "/resource/review/:id", ResourceController, :review
    post "/resource/check_url", ResourceController, :check_url

    post "/resource/tag-cloud", ResourceController, :tag_cloud
    post "resource/list", ResourceController, :list
    get "/resource/tag-cloud", ResourceController, :tag_cloud
    get "resource/list", ResourceController, :list

    # reflection
    post "/reflection/submission", ReflectionController, :submit
    post "/reflection", ReflectionController, :index
    get "/reflection", ReflectionController, :index
    post "/reflectionb", ReflectionController, :index_b
    get "/reflectionb", ReflectionController, :index_b
    post "/reflectionc", ReflectionController, :index_c
    get "/reflectionc", ReflectionController, :index_c
    get "/reflection/:id", ReflectionController, :index
    post "/reflection/:id", ReflectionController, :index

    # sig
    get "/user/select_sig_freestanding", UserController,
      :select_sig_freestanding
    post "/user/select_sig_freestanding", UserController,
      :select_sig_freestanding

    # review lesson designs
    # entrypoint:
    get "/lessondesigns/sidebar", LessonplanController, :sidebar
    post "/lessondesigns/sidebar", LessonplanController, :sidebar

    get "/lessondesigns/overview", LessonplanController, :overview
    post "/lessondesigns/overview", LessonplanController, :overview
    get "/lessondesigns/:id", LessonplanController, :detail
    post "/lessondesigns/:id", LessonplanController, :detail

    # commentstream
    post "/commentstream/submit", CommentstreamController, :submit

    # assessment
    post "/assessment", ReflectionController, :assessment
    get "/assessment", ReflectionController, :assessment
    post "/assessmentb", ReflectionController, :assessment_b
    get "/assessmentb", ReflectionController, :assessment_b
    post "/assessmentc", ReflectionController, :assessment_c
    get "/assessmentc", ReflectionController, :assessment_c
    post "/assessment/submit", ReflectionController, :assessment_submit
    get "/assessment/submit", ReflectionController, :assessment_submit
    post "/assessment/:id", ReflectionController, :assessment
    get "/assessment/:id", ReflectionController, :assessment

    # designgroups
    post "/design_groups/add_idea", DesignGroupController, :add_idea
    get "/design_groups/add_idea", DesignGroupController, :add_idea

    post "/design_groups/select", DesignGroupController, :select
    get "/design_groups/select", DesignGroupController, :select
    get "/design_groups/select/sidebar", DesignGroupController, :select_sidebar
    get "/design_groups/select/detail/:id", DesignGroupController, :select_detail
    get "/design_groups/select/overview", DesignGroupController, :overview
    post "/design_groups/select/submit", DesignGroupController, :submit

    get "/design_groups/comments", DesignGroupController, :comments
    post "/design_groups/comments", DesignGroupController, :comments

    post "/design_groups/submit_edit", DesignGroupController, :submit_edit

    # collaborative workbench
    post "/collab", CollabController, :index
    get "/collab", CollabController, :index
    post "/collab/leave", CollabController, :leave
    post "/collab/email", CollabController, :email

    # email notification control
    get "/email/unsubscribe/all", EmailController, :unsubscribe
    get "/email/unsubscribe/collab", EmailController, :unsubscribe_collab

    # review
    post "/review/submit", ReviewController, :submit
    get "/review/cancel", ReviewController, :cancel
    post "/review/cancel", ReviewController, :cancel
    post "/review/:id", ReviewController, :index
    get "/review/:id", ReviewController, :index

    # wiki review
    post "wiki-review", ReviewController, :wiki
    get "wiki-review", ReviewController, :wiki
    post "wiki-review/submit", ReviewController, :wiki_submit
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
    get "/report/text/:qid", ReportController, :fulltext
    post "/report/text/:qid", ReportController, :fulltext
    get "/report/tags", ReportController, :tags
    get "/report/resource", ResourceController, :report
    get "/report/designgroups", DesignGroupController, :report
    get "/report/designgroups/activity", AdminController, :group_activity
    get "/resource/preview", ResourceController, :preview
    get "/report/reflections", AdminController, :reflections
    get "/report/reflections/:id", AdminController, :reflections
    get "/report/reflections/text/:id/:qid", AdminController, :fulltext
    post "/report/reflections/text/:id/:qid", AdminController, :fulltext

    get "/collab/:id", CollabController, :admin
    get "/cohorts", AdminController, :cohorts

    get "/email/send_wk1", AdminController, :wk1
    get "/email/send_wk2", AdminController, :wk2
    # user info/debug
    get "/userinfo", UserController, :info
    post "/userinfo", UserController, :info

  end

  scope "/", Survey do
    pipe_through :public

    get "/email/:hash", EmailController, :redirect
    post "/email/:hash", EmailController, :redirect
  end
end
