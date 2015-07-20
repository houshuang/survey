defmodule Survey.Encore do
  use ExActor.Strict, export: :encore
  import Prelude

  @url Application.get_env(:confluence, :url)
  @wk1 String.strip(File.read!("data/wikitemplates/wk1.txt"))
  @disabled Application.get_env(:confluence, :disabled)

  defstart start_link do
    {:ok, token} = get_token
    initial_state(token)
  end

  defcall add_user(id), state: token do
    pwd = gen_password
    user = Survey.User.get(id)
    userdef = %{email: user.edx_email,
      name: String.downcase(user.edx_email),
      fullname: user.nick}
    case make_request("addUser", [userdef, pwd], token) do
      h = {:ok, _} ->
        %{ user | wiki_pwd: pwd } |> Survey.Repo.update!
        reply(h)
      h -> reply(h)
    end
  end

  defcall add_group_page(id), state: token do
    group = Survey.DesignGroup.get(id)
    page = %{content: @wk1,
      title: "#{group.id}: #{group.title}",
      space: "MOOC"}
    case make_request("storePage", page, token) do
      {:ok, resp} ->
        %{ group | wiki_url: String.replace(resp["url"], "http:", "https:") } |> Survey.Repo.update!
        {:ok, resp}
      x -> x
    end
    |> reply
  end

  defcall get_page(id), state: token do
    group = Survey.DesignGroup.get(id)
    req = case group.wiki_url do
      nil -> raise "No URL for this group"
      "https://wiki.mooc.encorelab.org/display/MOOC/" <> rest ->
        ["MOOC", rest]
      "https://wiki.mooc.encorelab.org/pages/viewpage.action?pageId=" <> rest ->
        [rest]
      x -> raise "Mismatch in URL: #{x}"
    end
    IO.inspect(req)
    case make_request("getPage", req, token) do
      {:ok, page} -> {:ok, page["content"]}
      x -> x
    end
    |> reply
  end

  def gen_password, do: :crypto.rand_bytes(20) |> safe_encode_base64

  def make_request(method, param, token) do
    request_body = %XMLRPC.MethodCall{method_name: "confluence2." <> method,
      params: List.flatten([token, param])}
    |> XMLRPC.encode!
    |> web_request
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
