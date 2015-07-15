defmodule Survey.RenderSurvey do
  alias Survey.Repo
  require Ecto.Query
  import Ecto.Query
  import Prelude
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
      # "grid" -> gridanswer(h)
      "radio" -> radioanswer(:radio, h, data)
      "multi" -> radioanswer(:multi, h, data)
      x -> []
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

  def radioanswer(type, h = {i, rest}, data) do
    case type do
      :radio -> {series, options} = radio(h, data)
      :multi -> {series, options} = multi(h, data)
    end

    labels = Poison.encode!(options)
    series = Poison.encode!(series)

    {:radio, %{labels: labels, series: series, question: rest}}
  end

  def radio({qid, rest}, data = {query, column}) do
    (from t in query, select: [count(t.id), 
      fragment("?->>? as x", field(t, ^column), ^qid)],
      where: (fragment("length(?->>?)", field(t, ^column), ^qid)) > 0,
      group_by: fragment("x"))
    |> multi_query({qid, rest}, data)
  end

  def multi({qid, rest}, data = {query, column}) do
    (from t in query, select: [
      fragment("count(jsonb_array_elements_text(?->?)) as count", field(t, ^column), ^qid),
      fragment("jsonb_array_elements_text(?->?) as x", field(t, ^column), ^qid)],
      group_by: fragment("x"))
    |> multi_query({qid, rest}, data)
  end

  def multi_query(query, {qid, rest}, data) do
    series = query
    |> Repo.all
    |> IO.inspect
    |> insert_defaults(length(rest.options))
    |> IO.inspect
    |> Enum.sort_by(fn [_, i] -> i end)
    |> Enum.map(fn [num, _] -> num end)
    |> List.insert_at(99, survey_length(data) - total_responses(qid, data))
    |> IO.inspect
    total = Enum.sum(series)

    series = Enum.map(series, fn num -> num/total end)

    { series, rest.options ++ ["no response"] }
  end

  def insert_defaults(series, num_def) do
    series
    |> Enum.map(fn [k, v] -> {v, k} end)
    |> Enum.into(%{})
    |> fn x -> 
      Map.merge(letter_range(num_def), x) 
      end.()
    |> Enum.map(fn {k, v} -> [v, k] end)
  end

  #---------------------------------------- 
  def textanswer({i, h}, data) do
    question = h[:name]
    answers = random_five_text(i, data)

    {:text, %{ answers: answers, question: h }}
  end
  
  def random_five_text(qid, {query, column}) do
    :random.seed(:os.timestamp)

    # get a list of filled in answers
    altquery = from p in query, select: p.id,
      where: fragment("length(?::jsonb->>?::text) > 0", field(p, ^column), ^qid)
    alternatives = altquery |> Repo.all 
    textids = 0..4 
    |> Enum.map(fn _ -> :random.uniform(Enum.count(alternatives)) end)
    |> Enum.map(fn x -> Enum.at(alternatives, x) end)

    (from p in query, 
      select: fragment("?::jsonb->?::text", field(p, ^column), ^qid),
      where: p.id in ^textids)
    |> Repo.all
  end

  def prepare_text({qid, rest}, search, data = {query, column}) do
    qid = Integer.to_string(qid)
    query = (from f in query, select: fragment("?->>?", field(f, ^column), ^qid),
      where: fragment("length(?->>?) > 0", field(f, ^column), ^qid))

    if search && search != "" do
      query = from f in query, 
      where: fragment("?->>? ILIKE '%?::text%'", field(f, ^column), ^qid, ^search)
    end

    answers = Repo.all(query)

    response_count = Enum.count(answers) 
    all_items_count = total_responses(qid, data)
    survey_length = survey_length(data)
    answer_percentage = all_items_count / survey_length

    assigns = %{
      answers: answers, 
      question: rest,
      percentage_answered: answer_percentage,
      response_count: response_count,
      search: search,
      all: false
    }
  end

  #-------------------------------------------
    def survey_length({query, column}) do
    (from p in query, select: count(p.id),
      where: not is_nil(field(p, ^column))) 
    |> Repo.one
    end

  def total_responses(qid, {query, column}) do
    (from p in query, select: count(p.id),
      where: fragment("length(?::jsonb->>?::text) > 0", field(p, ^column), ^qid))
    |> Repo.one
  end

  def letter_range(num) do
    1..num
    |> Enum.map(fn x -> {"#{[x + ?a - 1]}", 0} end)
    |> Enum.into(%{})
  end
    
end
