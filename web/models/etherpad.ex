defmodule Survey.Etherpad do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Etherpad
  alias Survey.DesignGroup
  import Ecto.Query
  require Ecto.Query
  alias Survey.Etherpad.API

  @week Application.get_env(:week, :current)
  @prompt File.read!("data/etherpad/#{@week}.txt")

  schema "etherpads" do
    field :week, :integer
    field :design_group_id, :integer
    field :hash, :string
  end

  def past_etherpads(group) do
    (from f in Etherpad,
    where: f.design_group_id == ^group,
    order_by: f.week)
    |> Repo.all
  end

  def find(group, week) do
    exist = (from f in Etherpad,
    where: f.week == ^week,
    where: f.design_group_id == ^group,
    select: f.hash)
    |> Repo.one
  end

  def ensure_etherpad(group) do
    exist = (from f in Etherpad,
    where: f.week == ^@week,
    where: f.design_group_id == ^group)
    |> Repo.one

    if exist do
      exist.hash
    else
      nonce = unique_nonce
      API.create_pad(nonce, @prompt)
      %Etherpad{week: @week, design_group_id: group, hash: nonce}
      |> Repo.insert!
      nonce
    end
  end

  def unique_nonce do
    nonce = gen_nonce
    if !Enum.empty?(lookup_hash(nonce)) do
      unique_nonce
    else
      nonce
    end
  end

  def lookup_hash(hash) do
    (from f in Etherpad,
    where: f.hash == ^hash)
    |> Repo.all
  end


  def gen_nonce do
    :random.seed(:os.timestamp)
    num = :random.uniform(999999) |> Integer.to_string
    manynums = num <> num <> num <> num <> num <> num
    String.ljust(manynums, 32, ?0)
  end

  def max_weeks do
    (from f in Etherpad,
    select: max(f.week))
    |> Repo.one
  end

end

