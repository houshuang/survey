defmodule Survey.User do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.User
  import Ecto.Query
  alias Ecto.Query
 
  import Prelude
  alias Survey.HTML.Survey, as: S
  @survey S.parse("data/survey.txt") |> S.index_mapping

  schema "users" do
    field :hash, :string
    field :nick, :string
    field :edx_email, :string
    field :edx_userid, :string
    field :tags, {:array, :string}
    field :grade, {:array, :string}
    field :role, {:array, :string}
    field :steam, {:array, :string}
    field :survey, Survey.JSON
    field :yearsteaching, :integer
    field :surveystate, :integer
    field :allow_email, :boolean
    field :admin, :boolean
    timestamps
  end

  @required_fields ~w(hash nick)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def get_qid(qid, search \\ nil) do
    query = from p in Survey.User, select: fragment("survey->? as x", ^qid)
    if search do
      query |> search_ci(qid, search)
    else
      query
    end
  end

  # def multi(qid) do
  #   question = @survey[String.to_integer(qid)]
  #   options = question.options

  # end

  def radio(qid) do
    question = @survey[String.to_integer(qid)]
    result = Ecto.Adapters.SQL.query(Survey.Repo, "SELECT count(id), survey->>'#{qid}' FROM 
      users WHERE length(survey->>'#{qid}')>0 GROUP BY survey->>'#{qid}';", [qid])
    series = result.rows
    |> Enum.sort_by(fn {_, i} -> i end)
    |> Enum.map(fn {num, key} -> num end)
    |> List.insert_at(99, survey_length - total_responses(qid))

    total = series |> Enum.sum

    series = series 
    |> Enum.map(fn num -> num/total end)

    { series, question.options ++ ["no response"] }
  end


  def answers(qid) do
    result = Ecto.Adapters.SQL.query(Survey.Repo, "SELECT count(id), survey->>'#{qid}' FROM 
      users WHERE length(survey->>'#{qid}')>0 GROUP BY survey->>'#{qid}';", [qid])
    result.rows
    |> Enum.sort_by(fn {_, i} -> String.to_integer(i) end)
    |> Enum.map(fn {x, i} -> x end)
    |> percentageify
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
    query = from p in Survey.User, select: p.id,
      where: fragment("length(survey->>?) > 0", ^qid)
    alternatives = query |> Repo.all 
    textids = 0..4 
    |> Enum.map(fn _ -> :random.uniform(Enum.count(alternatives)) end)
    |> Enum.map(fn x -> Enum.at(alternatives, x) end)

    query = from p in Survey.User, select: fragment("survey->?", ^qid),
      where: p.id in ^textids
    query |> Repo.all
  end
    

  def survey_length do
    query = from p in Survey.User, select: fragment("count(id)"),
      where: fragment("survey IS NOT NULL")
    query |> Repo.one
  end

  def total_responses(qid) do
    query = from p in Survey.User, select: fragment("count(id)"),
      where: fragment("length(survey->>?) > 0", ^qid)
    query |> Repo.one
  end

  def search_ci(query, qid, text) when is_binary(qid) do
    text = make_search(text)
    from p in query, where: fragment("survey->>? ILIKE ?", ^qid, ^text)
  end

  def get_all_qids(search \\ nil) do
    text = make_search(search)
    result = Ecto.Adapters.SQL.query(Survey.Repo, "WITH k AS (SELECT x FROM (SELECT survey->>'1' AS x FROM users) a UNION (SELECT survey->>'2' AS x FROM users) UNION (SELECT survey->>'3' AS x FROM users) UNION (SELECT survey->>'4' AS x FROM users))
SELECT x FROM k WHERE x ILIKE '#{text}'", [])
    Enum.map(result.rows, fn {x} -> x end)
  end

  defp and_and(query, col, val) when is_list(val) and is_atom(col) do
    from p in query, where: fragment("? && ?", ^val, field(p, ^col))
  end

  def make_search(nil), do: "%" 
  def make_search(q), do: "%" <> q <> "%"
end
