ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Hangman.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Hangman.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Hangman.Repo)

