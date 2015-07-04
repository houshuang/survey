defmodule Survey.Encore do
  def login do
    url = "https://www.encorewiki.org/rpc/xmlrpc"
    request_body = %XMLRPC.MethodCall{method_name: "confluence2.login", 
      params: [uname,pwd]}
    |> XMLRPC.encode!

    response = HTTPoison.post!(url, request_body).body
    |> XMLRPC.decode
  end
end
