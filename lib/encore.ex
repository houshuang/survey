defmodule Survey.Encore do
  use ExActor.Strict, export: :encore
  @url Application.get_env(:confluence, :url) 
  defstart start_link do
    get_token
  end

  defcall add_user, state: token do
    userdef = %{email: "shaklev@gmail.com",
      name: "stian",
      fullname: "Stian Haklev"}
    make_request("addUser", [userdef, "password"], token)
    |> reply
  end

  def make_request(method, param, token) do
    request_body = %XMLRPC.MethodCall{method_name: "confluence2." <> method,  
      params: List.flatten([token, param])}
    |> IO.inspect
    |> XMLRPC.encode!

    try do
      case HTTPoison.post!(@url, request_body).body |> XMLRPC.decode do
        {:ok, %{param: response}} -> response
        h = {:error, x} -> h
        h -> h
      end
    catch
      e -> {:error, Exception.message(e)}
    end
  end

    def get_token do
    url = Application.get_env(:confluence, :url)
    request_body = %XMLRPC.MethodCall{method_name: "confluence2.login", 
      params: [Application.get_env(:confluence, :username), Application.get_env(:confluence, :password)]}
    |> XMLRPC.encode!

    try do
      case HTTPoison.post!(url, request_body).body |> XMLRPC.decode do
        {:ok, %{param: response}} -> {:ok, response}
        h = {:error, x} -> h
        h -> h
      end
    catch
      e -> {:error, Exception.message(e)}
    end
  end

end
