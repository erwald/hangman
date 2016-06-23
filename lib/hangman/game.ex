defmodule Hangman.Game do
  use Timex

  defstruct phrase: "", guesses: [], last_guess_time: {0, 0, 0}, progress: :in_progress, max_guesses: 1

  @doc """
  Returns the initial state of a game.
  """
  def initial_state do
    %Hangman.Game{
      phrase: Enum.random(phrases),
      guesses: [],
      last_guess_time: Time.now,
      progress: :in_progress,
      max_guesses: 15
    }
  end

  @doc """
  Returns the game state as a prettily formated string.
  """
  def pretty_string(state) do
    phrase = state.phrase
    |> String.codepoints
    |> Enum.map(fn(x) ->
      if x =~ ~r/[a-zA-Z]/ && !Enum.member?(state.guesses, x) do
        "_"
      else
        x
      end
    end)
    guesses = state.guesses |> Enum.join(", ")
    remaining = state.max_guesses - Enum.count(state.guesses)
    "“#{phrase}”, with guesses: #{guesses} (#{remaining} remaining)"
  end

  @doc """
  A player makes a guess. If the guess has already been
  made, or if less than 2 seconds have passed since the
  last guess, it is ignored.
  """
  def guess(state, letter) do
    if Enum.member?(state.guesses, letter) || Time.elapsed(state.last_guess_time, :seconds) < 2 do
      state
    else
      updated_guesses = [letter | state.guesses]
      %{state | guesses: updated_guesses, last_guess_time: Time.now}
    end
  end

  @doc """
  Returns one of the following tuples:

    {true, :win}
    {true, :loss}
    {false, nil}
  """
  def is_finished?(state) do
    cond do
      is_lost?(state) -> {true, :loss}
      is_won?(state) -> {true, :win}
      true -> {false, nil}
    end
  end

  defp is_lost?(state) do
    Enum.count(state.guesses) > state.max_guesses
  end

  defp is_won?(state) do
    state.phrase
    |> unique_letters_in_phrase
    |> Enum.all?(fn(x) ->
      Enum.member?(state.guesses, x)
    end)
  end

  # Takes a string and returns a list of unique
  # letters (filtering out any non-letter characters).
  defp unique_letters_in_phrase(phrase) do
    phrase
    |> String.codepoints
    |> Enum.filter(fn(x) ->
      x =~ ~r/[a-zA-Z]/
    end)
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
