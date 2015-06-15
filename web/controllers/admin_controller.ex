defmodule Survey.AdminController do
  use Survey.Web, :controller

  require Logger
  alias Survey.User
  alias Survey.Repo
  import Ecto.Query
  require Ecto.Query

  #ffffff
  @colors Enum.reverse([ "#ffffff", "#d7191c", "#fdae61", "#ffffbf", 
    "#ffffbf", "#abd9e9", "#2c7bb6", "#ffffff"])

  plug :action
  alias Survey.HTML.Survey.Report
  alias Survey.HTML.Survey, as: S

  @survey S.parse("data/survey.txt") |> S.index_mapping
  def survey, do: @survey

  def stats(conn, params) do
    text conn, inspect(Report.generate("data/survey.txt", nil, nil, nil), pretty: true)
  end

  def textanswer(conn, %{"qid" => qid} = params) do 
    if qid == "" or qid == "all" or params["all"] do
      answers = User.get_all_qids(params["search"]) 
                |> Enum.filter(fn x -> x != nil end)
      response_count = Enum.count(answers) 
      conn 
      |> put_layout("statistics.html")
      |> render "textanswer.html", answers: answers, 
      question: %{number: 'all'},
      all: true,
      response_count: response_count,
      search: params["search"]
    else
      answers = User.get_qid(qid, params["search"]) 
                |> Repo.all
                |> Enum.filter(fn x -> x != nil end)
      response_count = Enum.count(answers) 
      all_items_count = User.total_responses(qid)
      survey_length = User.survey_length
      answer_percentage = all_items_count / survey_length
      conn 
      |> put_layout("statistics.html")
      |> render "textanswer.html", answers: answers, 
      question: @survey[String.to_integer(qid)],
      percentage_answered: answer_percentage,
      response_count: response_count,
      search: params["search"],
      all: false
    end
  end

  def grids(conn, params) do
    questions = 7..9 
    |> Enum.map(&gridanswer/1)

    conn 
    |> put_layout("statistics.html")
    |> render "multigrid.html", questions: questions
  end

  def gridanswer(qid) do 
    qid = Integer.to_string(qid)
    question = survey[String.to_integer(qid)]
    labels = Poison.encode!(question.rows)
    
    minmax = [ "", Enum.at(question.choicerange,0), 
      "","","","",Enum.at(question.choicerange,1), ""] 
    |> Enum.reverse
    |> Poison.encode!

    series = 0..Enum.count(question.rows)-1
    |> Enum.map(fn x -> "#{qid}.#{int_to_letter(x)}" end)
    |> Enum.map(&User.answers/1)
    |> User.recast
    |> Enum.reverse
    |> Enum.with_index
    |> Enum.map(fn {x, i} -> 
        %{data: x, color: Enum.at(@colors, i)}
      end)
    |> Poison.encode!

    %{ series: series, labels: labels, question: question,
      rowcount: Enum.count(question.rows), minmax: minmax }
  end

  def int_to_letter(i), do: "#{[i + ?a]}"
end
