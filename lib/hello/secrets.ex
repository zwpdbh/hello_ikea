defmodule Hello.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Hello.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:hello, :token_signing_secret)
  end
end
