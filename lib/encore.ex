defmodule Survey.Encore do
  use ExActor.Strict, export: :encore
  import Prelude
  import Ecto.Query
  require Ecto.Query

  @external_resource "data/wikitemplates/wk1.txt"
  @url Application.get_env(:confluence, :url)
  @wk1 String.strip(File.read!("data/wikitemplates/wk1.txt"))
  @wk1_freq String.strip(File.read!("data/wikitemplates/wk1.txt")) |> html_to_freq
  @disabled Application.get_env(:confluence, :disabled)

  defstart start_link do
    {:ok, token} = get_token
    initial_state(token)
  end

  defcall renew_token, state: token do
    {:ok, token} = get_token
    set_and_reply(token, :ok)
  end

  defcall token, state: token do
    reply(token)
  end

  def add_user(id) do
    pwd = gen_password
    user = Survey.User.get(id)
    userdef = %{email: user.edx_email,
      name: String.downcase(user.edx_email),
      fullname: user.nick}
    case make_request("addUser", [userdef, pwd]) do
      h = {:ok, _} ->
        %{ user | wiki_pwd: pwd } |> Survey.Repo.update!
        h
      h -> h
    end
  end

  def update_difference(id) do
    group = Survey.DesignGroup.get(id)
    diff = calc_difference(id)
    {:ok, rev, contrib} = get_revisions(id)

    %{ group |
      wiki_diff: diff,
      wiki_rev: rev,
      wiki_contributors: contrib
    } |> Survey.Repo.update!
    {:ok, :done}
  end

  def get_revisions(id) do
    pg = get_page(id) |> ok
    revs = make_request("getPageHistory", pg["id"]) |> ok
    curpage = get_page(id) |> ok
    revs = [ curpage | revs ]
    |> Enum.filter(fn %{"modifier" => mod} -> mod != "encore" end)
    len = length(revs)
    contrib = Enum.map(revs, fn %{"modifier" => mod} -> mod end)
    |> Enum.into(HashSet.new)
    |> HashSet.size
    {:ok, len, contrib}
  end

  def calc_difference(group) do
    {:ok, text} = get_page_contents(group)
    text = text
    |> html_to_freq
    |> Map.merge(@wk1_freq, fn k, v1, v2 -> v1 - v2 end)
    |> Enum.reduce(0, fn
      {_, nil}, acc          -> acc
      {_, v}, acc when v > 0 -> acc + v
      {_, _}, acc            -> acc
    end)
    case text do
      x when x < 4 -> 0
      x -> x
    end
  end

  def add_group_page(id) do
    group = Survey.DesignGroup.get(id)
    page = %{content: @wk1,
      title: "#{group.id}: #{group.title}",
      space: "MOOC"}
    case store_page(page) do
      {:ok, resp} ->
        %{ group | wiki_url: String.replace(resp["url"], "http:", "https:") } |> Survey.Repo.update!
        {:ok, resp}
      x -> x
    end
  end

  def get_page_contents(id) do
    case get_page(id) do
      {:ok, page} -> {:ok, page["content"]}
      x -> x
    end
  end

  def get_page(id) do
    group = Survey.DesignGroup.get(id)
    req = case group.wiki_url do
      nil -> raise "No URL for this group"
      "https://wiki.mooc.encorelab.org/display/MOOC/" <> rest ->
        ["MOOC", URI.decode_www_form(rest)]
      "https://wiki.mooc.encorelab.org/pages/viewpage.action?pageId=" <> rest ->
        [rest]
        x -> raise "Mismatch in URL: #{x}"
    end
    make_request("getPage", req)
  end

  def store_page(page) do
    make_request("storePage", page)
  end

  def update_wiki_cache(id) do
    case get_page(id) do
      {:ok, page} ->
        txt = Map.get(page, "content")
        rev = Map.get(page, "version")
        |> string_to_int_safe

        group = Survey.DesignGroup.get(id)
        old_cache_id = group.wiki_cache_id
        cache_id = Survey.Cache.store(txt)

        # if page has not changed, do nothing
        # if has changed, delete old entry, update design_group
        if cache_id != old_cache_id do
          if !is_nil(old_cache_id) do
            Survey.Cache.delete(old_cache_id)
          end
          %{ group | wiki_cache_id: cache_id, wiki_rev: rev - 1 } |> Survey.Repo.update!
        end
        {:ok, :done}

      x -> x
    end
  end

  def update_all_wiki_cache do
    (from f in Survey.DesignGroup,
    where: not is_nil(f.wiki_url),
    select: f.id)
    |> Survey.Repo.all
    |> Enum.map(fn id ->
      Survey.Job.add({Survey.Encore, :update_wiki_cache, [id]})
    end)
  end

  def gen_password, do: :crypto.rand_bytes(20) |> safe_encode_base64

  def make_request(method, param) do
    GenServer.call(:encore, {:make_request_internal, method, param}, 500000)
  end

  defcall make_request_internal(method, param), state: token do
    request_body = %XMLRPC.MethodCall{method_name: "confluence2." <> method,
      params: List.flatten([token, param])}
    |> XMLRPC.encode!
    |> web_request
    |> reply
  end

  def get_token do
    url = Application.get_env(:confluence, :url)
    request_body = %XMLRPC.MethodCall{method_name: "confluence2.login",
      params: [Application.get_env(:confluence, :username),
      Application.get_env(:confluence, :password)]}
    |> XMLRPC.encode!
    |> web_request
  end

  def web_request(request_body) do
    if !@disabled do
      try do
        case HTTPoison.post!(@url, request_body).body |> XMLRPC.decode do
          {:ok, %{param: response}} -> {:ok, response}
          h = {:error, x} -> h
          h -> {:error, h}
        end
      catch
        e -> {:error, Exception.message(e)}
      end
    else
      {:ok, :disabled}
    end
  end

end
