defmodule Hello.Accounts do
  use Ash.Domain, otp_app: :hello, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Hello.Accounts.Token
    resource Hello.Accounts.User
  end
end

defmodule Hello.Accounts.Play do
  def create_user() do
    Hello.Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: "zw@outlook.com",
      password: 123_456,
      password_confirmation: 123_456
    })
    |> Ash.create()
  end
end
