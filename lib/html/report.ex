defmodule Survey.HTML.Survey.Report do
  alias Survey.Repo
  alias Survey.User
  import Ecto.Query
  require Ecto.Query
  alias Ecto.Adapters.SQL
 
  alias Survey.HTML.Survey, as: S
  @survey S.parse("data/survey.txt") |> S.index_mapping
  def survey, do: @survey

  @steamsort %{"+" => 5, "A" => 3, "E" => 2, "M" => 4, "S" => 0, "T" => 1}
  @gradesort %{"4-6" => 1, "7-8" => 2, "9-12" => 3, "K-3" => 0, "noK12" => 4}


  def get_qid(qid, search \\ nil) do
    query = from p in User, select: fragment("survey->? as x", ^qid)
    if search do
      query |> search_ci(qid, search)
    else
      query
    end
  end

  def radio(qid) do
    question = @survey[String.to_integer(qid)]
    result = SQL.query(Survey.Repo, "SELECT count(id), survey->>'#{qid}' FROM 
      users WHERE length(survey->>'#{qid}')>0 GROUP BY survey->>'#{qid}';", [qid])
    series = result.rows
    |> Enum.sort_by(fn {_, i} -> i end)
    |> Enum.map(fn {num, _} -> num end)
    |> List.insert_at(99, survey_length - total_responses(qid))

    total = series |> Enum.sum

    series = series 
    |> Enum.map(fn num -> num/total end)

    { series, question.options ++ ["no response"] }
  end

  def answers(qid, subq) do
    result = SQL.query(Survey.Repo, 
      "SELECT count(id), survey->>'#{subq}' FROM users WHERE length(survey->>'#{subq}')>0 
      GROUP BY survey->>'#{subq}';", [])

    if result.num_rows == 0 do
      [0, 0, 0, 0, 0, 0, 0, 0]
    else
      question = result.rows
      |> pad_rows(qid) # also reverses order
      |> Enum.sort_by(fn {i, _} -> String.to_integer(i) end)
      |> Enum.map(fn {_, x} -> x end)
      |> percentageify
    end
  end

  # if there are no data points for some of the columns, have to add 0s to make
  # the alignment work, ideally percentageify should also be changed to deal
  # with arbitrary many options.
  def pad_rows(rows, qid) do
    question = get_question(qid)

    size = Enum.at(question.choicerange, 2)
    |> String.to_integer

    padding = 1..size
    |> Enum.map(fn x -> {Integer.to_string(x), 0} end)
    |> Enum.into(%{})

    if Enum.empty?(rows) do
      padding
    else
      rows = rows
      |> Enum.map(fn {k, v} -> {v, k} end)
      |> Enum.into(%{})
      
      Map.merge(padding, rows)
    end
  end

  def percentageify(lst) do
    sum = Enum.sum(lst)
    perclst = Enum.map(lst, fn x -> x/sum end)
    left = Enum.at(perclst, 0) + Enum.at(perclst, 1) + (Enum.at(perclst, 2) / 2)
    lbuffer = (1 - left) 
    rbuffer = 1 - (Enum.sum(perclst) - left)
    [ lbuffer, 
      Enum.at(perclst, 0), 
      Enum.at(perclst, 1), 
      (Enum.at(perclst, 2)/2), 
      (Enum.at(perclst, 2)/2), 
      Enum.at(perclst, 3), 
      Enum.at(perclst, 4), 
      rbuffer ]
    |> Enum.map(fn x -> clean_nils(x, 0) end)
    |> Enum.map(fn x -> round(x * 100) end)
  end

  def clean_nils(nil, alt), do: alt
  def clean_nils(x, _), do: x

  def recast(lsts) do
    acc = 1..Enum.count(Enum.at(lsts, 0)) |> Enum.map(fn _ -> [] end)
    Enum.reduce(lsts, acc, fn x, acc ->
      acc
      |> Enum.with_index
      |> Enum.map(fn {y, i} -> [Enum.at(x, i) | y] end)
    end)
    |> Enum.map(fn x -> Enum.reverse(x) end)
  end

  def random_five_text(qid) do
    :random.seed(:os.timestamp)

    # get a list of filled in answers
    query = from p in User, select: p.id,
      where: fragment("length(survey->>?) > 0", ^qid)
    alternatives = query |> Repo.all 
    textids = 0..4 
    |> Enum.map(fn _ -> :random.uniform(Enum.count(alternatives)) end)
    |> Enum.map(fn x -> Enum.at(alternatives, x) end)

    query = from p in User, select: fragment("survey->?", ^qid),
      where: p.id in ^textids
    query |> Repo.all
  end
    

  def survey_length do
    query = from p in User, select: fragment("count(id)"),
      where: fragment("survey IS NOT NULL")
    query |> Repo.one
  end

  def total_responses(qid) do
    query = from p in User, select: fragment("count(id)"),
      where: fragment("length(survey->>?) > 0", ^qid)
    query |> Repo.one
  end

  def search_ci(query, qid, text) when is_binary(qid) do
    text = make_search(text)
    from p in query, where: fragment("survey->>? ILIKE ?", ^qid, ^text)
  end

  def get_all_qids(search \\ nil) do
    text = make_search(search)
    query = 
    "WITH k AS (SELECT x FROM (SELECT survey->>'1' AS x FROM users) a 
    UNION (SELECT survey->>'2' AS x FROM users) UNION (SELECT survey->>'3' 
    AS x FROM users) UNION (SELECT survey->>'4' AS x FROM users))
    SELECT x FROM k WHERE x ILIKE '#{text}'"
    Enum.map(runq(query), fn {x} -> x end)
  end

  defp and_and(query, col, val) when is_list(val) and is_atom(col) do
    from p in query, where: fragment("? && ?", ^val, field(p, ^col))
  end

  def steam_number do
    runq(
    "WITH lengths AS (SELECT array_length(steam,1) AS length FROM users)
    SELECT length, count(length) AS COUNT FROM lengths GROUP BY length ORDER BY
    length;")
  end

  def steams do
    runq(
    "WITH steams AS (SELECT unnest(steam) AS steam FROM users)
    SELECT steam, count(steam) AS COUNT FROM steams GROUP BY steam ORDER BY steam
    desc;")
    |> Enum.sort_by(fn {steam, x} -> @steamsort[steam] end)
  end

  def grades do
    runq(
    "WITH grades AS (SELECT unnest(grade) AS grade FROM users) SELECT grade,
    count(grade) AS COUNT FROM grades GROUP BY grade ORDER BY COUNT DESC ;")
    |> Enum.sort_by(fn {grade, x} -> @gradesort[grade] end)
  end

  def tags do
    runq(
    "WITH tagstmp AS (SELECT nick, unnest(tags) AS tag, steam, grade FROM
    users), tagcount AS (SELECT tag, count(tag) AS COUNT FROM tagstmp GROUP BY
    tag ORDER BY COUNT desc) SELECT tagcount.tag, tagcount.COUNT, tags.steam,
    tags.grade FROM tagcount, tags WHERE tagcount.tag = tags.tag;")
    |> Enum.map(&sort_tag_entry/1)
  end

  def sigs do
    runq(
    "SELECT s.name AS name, count(u.id) AS COUNT FROM users AS u LEFT JOIN sigs AS s ON u.sig_id = s.id WHERE s.name IS NOT NULL GROUP BY s.name ORDER BY COUNT desc;")
  end

  def sort_tag_entry({tag, count, steam, grade}) do
    {
      tag,
      count,
      Enum.sort_by(steam, fn x -> @steamsort[x] end),
      Enum.sort_by(grade, fn x -> @gradesort[x] end),
    }
  end

  def runq(query, opts \\ []) do
    result = SQL.query(Survey.Repo, query, [])
    result.rows
  end

  def make_search(nil), do: "%" 
  def make_search(q), do: "%" <> q <> "%"

  def get_question(qid) when is_binary(qid), do: survey[String.to_integer(qid)]
end
