defmodule Survey.Repo.Migrations.SigList do
  use Ecto.Migration

  def up do
    Survey.Repo.delete_all(Survey.SIG)
    File.stream!("data/sigs.txt")
    |> Stream.map(&String.strip/1)
    |> Enum.each(&add_sig/1)
  end

  def down do
  end

  def add_sig(sig) do
    %Survey.SIG{name: sig} |> Survey.Repo.insert
  end
end

