defmodule Hello.Accounts.User.Types.Source do
  use Ash.Type.Enum, values: [:agent, :user]
end
