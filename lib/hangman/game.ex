defmodule Hangman.Game do
  use Timex

  @min_time_after_guess 2 # In seconds.

  defstruct phrase: "",
    guesses: [],
    last_guess_time: {0, 0, 0},
    progress: :in_progress,
    max_guesses: 1

  @doc """
  Returns the initial state of a game.
  """
  def initial_state do
    phrase = Enum.random(phrases)
    max_guesses = (phrase |> unique_letters_in_string |> Enum.count) + 5

    %Hangman.Game{
      phrase: phrase,
      guesses: [],
      last_guess_time: Time.now,
      progress: :in_progress,
      max_guesses: max_guesses
    }
  end

  @doc """
  Returns the game state scrubbed from data that the players shouldn't see.
  """
  def scrubbed_state(state) do
    state
    |> Map.put(:phrase, scrubbed_phrase(state))
    |> Map.take([:phrase, :guesses, :progress, :max_guesses])
  end

  defp scrubbed_phrase(state) do
    state.phrase
    |> String.codepoints
    |> Enum.map(fn(x) ->
      has_been_guessed = Enum.member?(state.guesses, String.downcase(x))
      is_revealed = has_been_guessed || is_finished?(state)
      if x =~ ~r/[a-z]/i && !is_revealed, do: "_", else: x
    end)
  end

  @doc """
  A player makes a guess. If the game is over, or if the guess has already been
  made, or if less than 2 seconds have passed since the last guess, it is
  ignored.
  """
  def guess(state, letter) do
    cond do
      !(letter =~ ~r/^[a-z]$/i) ->
        {:invalid_entry, state}
      state.progress != :in_progress ->
        {:finished, state}
      Enum.member?(state.guesses, letter) ->
        {:duplicate, state}
      Time.elapsed(state.last_guess_time, :seconds) < @min_time_after_guess ->
        {:too_soon, state}
      true ->
        new_guesses = [String.downcase(letter) | state.guesses] |> Enum.sort
        new_state = %{state | guesses: new_guesses, last_guess_time: Time.now}
        new_progress = cond do
          is_won?(new_state) -> :won
          is_lost?(new_state) -> :lost
          true -> :in_progress
        end
        {:ok, %{new_state | progress: new_progress}}
    end
  end

  # Determines whether a given game is finished or still in progress.
  defp is_finished?(state), do: is_won?(state) || is_lost?(state)

  # Determines whether a given game was won.
  defp is_won?(state) do
    state.phrase
    |> unique_letters_in_string
    |> Enum.all?(fn(x) ->
      Enum.member?(state.guesses, x)
    end)
  end

  # Determines whether a given game was lost.
  defp is_lost?(state), do: Enum.count(state.guesses) >= state.max_guesses

  # Takes a string and returns a list of unique lowercase letters (filtering out
  # any non-letter characters).
  defp unique_letters_in_string(string) do
    string
    |> String.downcase
    |> String.codepoints
    |> Enum.filter(fn(x) ->
      x =~ ~r/[a-z]/
    end)
    |> Enum.uniq
  end

  defp phrases do
    [
      "I don’t have a TV!",
      "I never eat meat!",
      "I walk ten miles a day!",
      "My diet is making me lose a lot of weight!",
      "I use my own waste to grow food!",
      "My children aren’t vaccinated!",
      "I have a very small carbon footprint!",
      "I don’t vote — the system is too corrupt!"
    ]
  end
end
