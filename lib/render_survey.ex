# TODO: figure out how to parametrize queries on jsonb, otherwise hardcode
# for now... at least finish radio, and add multi (or not necessary) and get
# it rendering for Jim

defmodule Survey.RenderSurvey do
  alias Survey.Repo
  require Ecto.Query
  import Ecto.Query
  @colors Enum.reverse([ "#ffffff", "#d7191c", "#fdae61", "#ffffbf", 
    "#ffffbf", "#abd9e9", "#2c7bb6", "#ffffff"])

  #----------------------------------------

  def render_survey(question_def, data) do
    question_def
    |> Enum.map(fn {k, v} -> {Integer.to_string(k), v} end)
    |> Enum.map(fn x -> do_question(x, data) end)
  end

  def do_question(h = {i, %{type: type}}, data) do
    case type do
      "textbox" -> textanswer(h, data)
      x -> []
      # "grid" -> gridanswer(h)
      # "radio" -> radioanswer(h)
    end
  end

  # def text(conn, %{"qid" => qid} = params) do 
    # if qid == "" or qid == "all" or params["all"] do
    #   answers = Report.get_all_qids(params["search"]) 
    #             |> Enum.filter(fn x -> x != nil end)
    #   response_count = Enum.count(answers) 

    #   assigns = %{
    #     answers: answers, 
    #     question: %{number: 'all'},
    #     all: true,
    #     response_count: response_count,
    #     search: params["search"]
    #   }
    # else
    #   answers = Report.get_qid(qid, params["search"]) 
    #             |> Repo.all
    #             |> Enum.filter(fn x -> x != nil end)
    #   response_count = Enum.count(answers) 
    #   all_items_count = Report.total_responses(qid)
    #   survey_length = Report.survey_length
    #   answer_percentage = all_items_count / survey_length

    #   assigns = %{
    #     answers: answers, 
    #     question: Report.get_question(qid),
    #     percentage_answered: answer_percentage,
    #     response_count: response_count,
    #     search: params["search"],
    #     all: false
    #     }
    # end

    # conn 
    # |> put_layout("report.html")
    # |> render "textanswer.html", assigns  

  # end

  # def gridanswer(qid) do 
    # question = Report.get_question(qid)
    # labels = Poison.encode!(question.rows)

    # minmax = [ "", Enum.at(question.choicerange,0), 
    #   "","","","",Enum.at(question.choicerange,1), ""] 
    # |> Enum.reverse
    # |> Poison.encode!

    # series = 0..Enum.count(question.rows)-1
    # |> Enum.map(fn x -> "#{qid}.#{int_to_letter(x)}" end)
    # |> Enum.map(fn x -> Report.answers(qid, x) end)
    # |> Report.recast
    # |> Enum.reverse
    # |> Enum.with_index
    # |> Enum.map(fn {x, i} -> 
    #     %{data: x, color: Enum.at(@colors, i)}
    #   end)
    # |> Poison.encode!

    # {:grid, %{ series: series, labels: labels, question: question,
    #     rowcount: Enum.count(question.rows), minmax: minmax }}
  # end

  def radioanswer({i, h}, data) do
    # {series, options} = Report.radio(qid)
    # labels = Poison.encode!(options)
    # series = Poison.encode!(series)

    # {:radio, %{labels: labels, series: series, question: question}}
  end

  def radio(qid, {query, column}) do
    # result = (from t in query, select: [count(t.id), 
    #   fragment("?->>?", field(t, ^column), ^qid)],
    #   where: (fragment("length(?->>?)", field(t, ^column), ^qid)) > 0,
    #   group_by: fragment("?->>?", field(t, ^column), ^qid))
    #   |> Repo.all
    result = runq(
    "SELECT count(id), response>>'#{qid}' FROM 
      users WHERE length(response>>'#{qid}')>0 GROUP BY response>>'#{qid}';", [qid])
      
      # users WHERE length(survey->>'#{qid}')>0 GROUP BY survey->>'#{qid}';", [qid])
    # series = result.rows
    # |> Enum.sort_by(fn {_, i} -> i end)
    # |> Enum.map(fn {num, _} -> num end)
    # |> List.insert_at(99, survey_length - total_responses(qid))

    # total = series |> Enum.sum

    # series = series 
    # |> Enum.map(fn num -> num/total end)

    # { series, question.options ++ ["no response"] }
  end

  #---------------------------------------- 
  def textanswer({i, h}, data) do
    question = h[:name]
    answers = random_five_text(i, data)

    {:text, %{ answers: answers, question: question }}
  end
  
  def random_five_text(qid, {query, column}) do
    :random.seed(:os.timestamp)

    # get a list of filled in answers
    altquery = from p in query, select: p.id,
      where: fragment("length(?::jsonb->>?::text) > 0", field(p, ^column), ^qid)
    alternatives = altquery |> Repo.all 
    IO.inspect(alternatives)
    textids = 0..4 
    |> Enum.map(fn _ -> :random.uniform(Enum.count(alternatives)) end)
    |> Enum.map(fn x -> Enum.at(alternatives, x) end)

    query = from p in query, select: fragment("?::jsonb->?::text", field(p, ^column), ^qid),
      where: p.id in ^textids
    query |> Repo.all
    |> IO.inspect
  end
end
