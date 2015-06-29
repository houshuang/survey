defmodule Survey.ReportController do
  use Survey.Web, :controller

  require Logger
  import Ecto.Query
  require Ecto.Query

  alias Survey.Repo
  alias Survey.HTML.Survey.Report

  #ffffff
  @colors Enum.reverse([ "#ffffff", "#d7191c", "#fdae61", "#ffffbf", 
    "#ffffbf", "#abd9e9", "#2c7bb6", "#ffffff"])
  @survey Report.survey

  plug :action
  #----------------------------------------

  def index(conn, _) do
    questions = Report.survey
                |> Enum.map(&do_question/1)
    
    questions = 
    [ { :sigs, Report.sigs },
      { :tags, Report.tags },
      { :grades, Report.grades },
      { :steams, %{steams: Report.steams, steamnumber: Report.steam_number} }
      | questions ]

    conn 
    |> put_layout("report.html")
    |> render "index.html", questions: questions
  end

  def do_question({i, %{type: type}}) do
    qid = Integer.to_string(i)
    case type do
      "textbox" -> textanswer(qid)
      "grid" -> gridanswer(qid)
      "radio" -> radioanswer(qid)
    end
  end

  #----------------------------------------

  def tags(conn, _) do
    conn 
    |> put_layout("report.html")
    |> render "tags.html", data: Report.tags
  end

  def text(conn, %{"qid" => qid} = params) do 
    if qid == "" or qid == "all" or params["all"] do
      answers = Report.get_all_qids(params["search"]) 
                |> Enum.filter(fn x -> x != nil end)
      response_count = Enum.count(answers) 

      assigns = %{
        answers: answers, 
        question: %{number: 'all'},
        all: true,
        response_count: response_count,
        search: params["search"]
      }
    else
      answers = Report.get_qid(qid, params["search"]) 
                |> Repo.all
                |> Enum.filter(fn x -> x != nil end)
      response_count = Enum.count(answers) 
      all_items_count = Report.total_responses(qid)
      survey_length = Report.survey_length
      answer_percentage = all_items_count / survey_length

      assigns = %{
        answers: answers, 
        question: Report.get_question(qid),
        percentage_answered: answer_percentage,
        response_count: response_count,
        search: params["search"],
        all: false
        }
    end

    conn 
    |> put_layout("report.html")
    |> render "textanswer.html", assigns  

  end

  #----------------------------------------

  def gridanswer(qid) do 
    question = Report.get_question(qid)
    labels = Poison.encode!(question.rows)

    minmax = [ "", Enum.at(question.choicerange,0), 
      "","","","",Enum.at(question.choicerange,1), ""] 
    |> Enum.reverse
    |> Poison.encode!

    series = 0..Enum.count(question.rows)-1
    |> Enum.map(fn x -> "#{qid}.#{int_to_letter(x)}" end)
    |> Enum.map(fn x -> Report.answers(qid, x) end)
    |> Report.recast
    |> Enum.reverse
    |> Enum.with_index
    |> Enum.map(fn {x, i} -> 
        %{data: x, color: Enum.at(@colors, i)}
      end)
    |> Poison.encode!

    {:grid, %{ series: series, labels: labels, question: question,
        rowcount: Enum.count(question.rows), minmax: minmax }}
  end

  def textanswer(qid) when is_binary(qid) do
    question = Report.get_question(qid)
    answers = Report.random_five_text(qid)

    {:text, %{ answers: answers, question: question }}
  end

  def radioanswer(qid) when is_binary(qid) do
    question = Report.get_question(qid)

    {series, options} = Report.radio(qid)
    labels = Poison.encode!(options)
    series = Poison.encode!(series)

    {:radio, %{labels: labels, series: series, question: question}}
  end

  # ----------------------------------------
  # helpers
  # ----------------------------------------

  def int_to_letter(i), do: "#{[i + ?a]}"
end
