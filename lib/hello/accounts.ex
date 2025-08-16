defmodule Hello.Accounts do
  use Ash.Domain, otp_app: :hello, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Hello.Accounts.Token

    resource Hello.Accounts.User do
      define :get_user_by_id, action: :read, get_by: :id
    end
  end
end

defmodule Hello.Accounts.Play do
  def create_user() do
    Hello.Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: "zw@outlook.com",
      password: "gghh3344",
      password_confirmation: "gghh3344"
    })
    |> Ash.create()
  end

  def query_user() do
    Hello.Accounts.User
    |> Ash.Query.for_read(:read)
    |> Ash.Query.sort(email: :asc)
    |> Ash.read(authorize?: false)
  end

  def get_user_by_id_from_interface() do
    Hello.Accounts.get_user_by_id("e323bd6c-eae5-4312-8e4a-cbea898714ca", authorize?: false)
  end

  def get_user_by_id_from_query() do
    Hello.Accounts.User
    |> Ash.Query.for_read(:read)
    |> Ash.read(authorize?: false)
  end
end
