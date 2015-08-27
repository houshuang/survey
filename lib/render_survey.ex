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
      "text" -> textanswer(h, data)
      # "grid" -> gridanswer(h, data)
      "radio" -> radioanswer(:radio, h, data)
      "multi" -> radioanswer(:multi, h, data)
      x -> []
    end
  end

  # def answers(qid, subq, {query, column}) do
  #   result =
  #   (from t in query, select: [count(t.id),
  #     fragment("?->>? as x", field(t, ^column), ^subq)],
  #     where: (fragment("length(?->>?)", field(t, ^column), ^subq)) > 0,
  #     group_by: fragment("x"))
  #     |> Repo.all

  #   if result.num_rows == 0 do
  #     [0, 0, 0, 0, 0, 0, 0, 0]
  #   else
  #     question = result.rows
  #     |> pad_rows(qid) # also reverses order
  #     |> Enum.sort_by(fn {i, _} -> String.to_integer(i) end)
  #     |> Enum.map(fn {_, x} -> x end)
  #     |> percentageify
  #   end
  # end

  # def pad_rows(rows, qid) do
  #   question = get_question(qid)

  #   size = Enum.at(question.choicerange, 2)
  #   |> String.to_integer

  #   padding = 1..size
  #   |> Enum.map(fn x -> {Integer.to_string(x), 0} end)
  #   |> Enum.into(%{})

  #   if Enum.empty?(rows) do
  #     padding
  #   else
  #     rows = rows
  #     |> Enum.map(fn {k, v} -> {v, k} end)
  #     |> Enum.into(%{})

  #     Map.merge(padding, rows)
  #   end
  # end

  # def percentageify(lst) do
  #   sum = Enum.sum(lst)
  #   perclst = Enum.map(lst, fn x -> x/sum end)
  #   left = Enum.at(perclst, 0) + Enum.at(perclst, 1) + (Enum.at(perclst, 2) / 2)
  #   lbuffer = (1 - left)
  #   rbuffer = 1 - (Enum.sum(perclst) - left)
  #   [ lbuffer,
  #     Enum.at(perclst, 0),
  #     Enum.at(perclst, 1),
  #     (Enum.at(perclst, 2)/2),
  #     (Enum.at(perclst, 2)/2),
  #     Enum.at(perclst, 3),
  #     Enum.at(perclst, 4),
  #     rbuffer ]
  #   |> Enum.map(fn x -> clean_nils(x, 0) end)
  #   |> Enum.map(fn x -> round(x * 100) end)
  # end

  # def clean_nils(nil, alt), do: alt
  # def clean_nils(x, _), do: x

  # def recast(lsts) do
  #   acc = 1..Enum.count(Enum.at(lsts, 0)) |> Enum.map(fn _ -> [] end)
  #   Enum.reduce(lsts, acc, fn x, acc ->
  #     acc
  #     |> Enum.with_index
  #     |> Enum.map(fn {y, i} -> [Enum.at(x, i) | y] end)
  #   end)
  #   |> Enum.map(fn x -> Enum.reverse(x) end)
  # end

  # def gridanswer({qid, question}, data = {query, column}) do
  #   labels = Poison.encode!(question.rows)

  #   minmax = [ "", Enum.at(question.choicerange,0),
  #     "","","","",Enum.at(question.choicerange,1), ""]
  #   |> Enum.reverse
  #   |> Poison.encode!

  #   series = 0..Enum.count(question.rows)-1
  #   |> Enum.map(fn x -> "#{qid}.#{int_to_letter(x)}" end)
  #   |> Enum.map(fn x -> answers.(qid, x, data) end)
  #   |> Report.recast
  #   |> Enum.reverse
  #   |> Enum.with_index
  #   |> Enum.map(fn {x, i} ->
  #       %{data: x, color: Enum.at(@colors, i)}
  #     end)
  #   |> Poison.encode!

  #   {:grid, %{ series: series, labels: labels, question: question,
  #       rowcount: Enum.count(question.rows), minmax: minmax }}
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
    |> insert_defaults(length(rest.options))
    |> Enum.sort_by(fn [_, i] -> i end)
    |> Enum.map(fn [num, _] -> num end)
    |> List.insert_at(99, survey_length(data) - total_responses(qid, data))
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
