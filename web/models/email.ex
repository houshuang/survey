defmodule Survey.Email do
  use Survey.Web, :model
  alias Survey.Repo
  require Ecto.Query
  import Ecto.Query
  alias Survey.Email

  schema "emails" do
    field :design_group_id, :integer
    field :from_id, :integer
    field :subject, :string
    field :content, :string
    field :from_web, :boolean
    timestamps updated_at: false
  end

  def insert(design_id, from_id, subject, content, from_web) do
    %Email{design_group_id: design_id,
      from_id: from_id,
      subject: subject,
      content: content,
      from_web: from_web}
    |> Repo.insert!
  end

  def num_by_group do
    (from f in Email,
    select: [f.design_group_id, count(f.id)],
    group_by: f.design_group_id)
    |> Repo.all
    |> Enum.map(fn [k, v] -> {k, v} end)
    |> Enum.into(%{})
  end
end

