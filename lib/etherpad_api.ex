defmodule Survey.Etherpad.API do
  import Prelude

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
     gen_request(command, map)
     |> HTTPoison.get! 
   end

   def create_pad(id, text \\ nil) do
     map = %{padID: id}
     if text do
       map = Map.put(map, :text, text)
     end
     run("createPad", map)
   end
end
