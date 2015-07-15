defmodule Mix.Tasks.Parse.Reflections do
  use Mix.Task

  @shortdoc "Parses reflections in data/reflections and inserts HTML into 
  database"

  def run(_) do
    Survey.HTML.Reflections.parse_all
  end
end

defmodule Survey.HTML.Reflections do
  alias Survey.Prompt
  alias Survey.Repo
  alias Survey.HTML.Survey

  def parse_all do
    Repo.start_link
    Repo.delete_all(Prompt)

    get_file_list
    |> Enum.each(&gen_struct/1)
  end

  def gen_struct({i, file}) do
    struct = Survey.parse(file)
    questions = Survey.index_mapping(struct)
    html = Survey.gen_survey_from_struct(struct, :f)
    IO.puts("Parsing and storing #{file}")
    %Prompt{
      name: file,
      id: String.to_integer(i),
      definition: File.read!(file),
      html: html,
      question_def: questions}
    |> Repo.insert!
  end

  def get_file_list do
    Path.wildcard("data/reflections/*.txt")
    |> Enum.map(fn x -> {extract_num(x), x} end)
  end

  def extract_num(x) do
    Path.basename(x, ".txt")
  end
end
