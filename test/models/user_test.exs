defmodule Survey.UserTest do
  use Survey.ModelCase

  alias Survey.User

  @valid_attrs %{hash: "some content", nick: "some content", tags: []}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
