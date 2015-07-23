defmodule Survey.Etherpad.API do
  import Prelude
  @prompts get_file_list("etherpad")

  def gen_request(command, map) do
    mapstr = map
    |> stringify_map
    |> Enum.map(fn {k, v} -> "#{URI.encode_www_form(k)}=#{URI.encode_www_form(v)}" end)
    |> Enum.join("&")

    base_url = Application.get_env(:etherpad, :base_url)
    api_key = Application.get_env(:etherpad, :api_key)
    "#{base_url}/api/1/#{command}?apikey=#{api_key}&#{mapstr}"
  end

  def run(command, map) do
    case gen_request(command, map) |> HTTPoison.get! do
      %{body: body} -> case Poison.decode!(body) do
        %{"code" => 0, "data" => data} -> {:ok, data}
        x -> {:error, x}
      end
      x -> {:error, x}
    end
  end

  def create_pad(id, text \\ nil) do
    map = %{padID: id}
    if text do
      map = Map.put(map, :text, text)
    end
    run("createPad", map)
  end

  def get_rev_count(id) do
    map = %{padID: id}
    case run("getRevisionsCount", map) do
      {:ok, %{"revisions" => rev}} -> {:ok, rev}
      x -> x
    end
  end

  def get_text(id) do
    map = %{padID: id}
    case run("getText", map) do
      {:ok, %{"text" => rev}} -> {:ok, rev}
      x -> x
    end
  end

  def get_authors(hash, week) do
    map = %{padID: hash}
    {:ok, %{"authorIDs" => ids}} = run("listAuthorsOfPad", map)
    length(ids)
  end

  def update_difference(group) do
    rev = Survey.Etherpad.past_etherpads(group)
    |> Enum.map(fn x ->
      {x.week, %{diff: calc_difference(x.hash, x.week), authors: get_authors(x.hash, x.week)}}
    end)
    |> Enum.into(%{})
    group = Survey.DesignGroup.get(group)
    %{ group | etherpad_rev: rev } |> Survey.Repo.update!
    {:ok, :done}
  end

  def calc_difference(hash, week) do
    {:ok, text} = get_text(hash)
    {wk, prompt} = Enum.at(@prompts, week - 1)
    String.split(prompt, "\n")
    |> Enum.reduce(text, fn x, acc -> String.replace(acc, prompt, "") end)
    |> String.split(" ")
    |> Enum.filter(fn x -> x != "" end)
    |> length
    |> case do
      x when x < 10 -> nil
      x -> x
    end
  end
end
