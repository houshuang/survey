defmodule Survey.Encore do
  use ExActor.Strict, export: :encore
  @url Application.get_env(:confluence, :url) 
  defstart start_link do
    {:ok, token} = get_token
    initial_state(token)
  end

  defcall add_user(id), state: token do
    pwd = gen_password
    user = Survey.User.get(id)
    userdef = %{email: user.edx_email,
      name: user.edx_email,
      fullname: user.nick}
    make_request("addUser", [userdef, pwd], token)
    |> reply
  end

  def gen_password, do: :crypto.rand_bytes(20) |> Base.encode64

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
    try do
      case HTTPoison.post!(@url, request_body).body |> XMLRPC.decode do
        {:ok, %{param: response}} -> {:ok, response}
        h = {:error, x} -> h
        h -> {:error, h}
      end
    catch
      e -> {:error, Exception.message(e)}
    end
  end

end
