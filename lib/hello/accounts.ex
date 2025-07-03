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
