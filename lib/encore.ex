defmodule Survey.Encore do
  def login do
    url = Application.get_env(:confluence, :url)
    request_body = %XMLRPC.MethodCall{method_name: "confluence2.login", 
      params: [Application.get_env(:confluence, :username), Application.get_env(:confluence, :password)]}
    |> IO.inspect
    |> XMLRPC.encode!

    response = HTTPoison.post!(url, request_body).body
    |> XMLRPC.decode
  end
end
