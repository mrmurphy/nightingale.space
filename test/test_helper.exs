ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Nightingale.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Nightingale.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Nightingale.Repo)

