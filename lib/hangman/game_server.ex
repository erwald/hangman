defmodule Hangman.GameServer do
  use GenServer

  ## Client API

  @doc """
  Starts a new game server.
  """
  def start_link(name) do
    IO.puts "Starting a new game of hangman."
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  Gets the current game state.
  """
  def get_state(pid), do: GenServer.call(pid, :get_state)

  @doc """
  A player makes a guess.
  """
  def guess(pid, letter) do
    IO.puts "Somebody is guessing #{letter}."
    GenServer.call(pid, {:guess, letter})
  end

  ## Server Callbacks

  def init(:ok), do: {:ok, Hangman.Game.initial_state}

  # Gets the state as a nicely formatted string.
  def handle_call(:get_state, _from, state) do
    {:reply, state |> Hangman.Game.pretty_string, state}
  end

  def handle_call({:guess, letter}, _from, state) do
    {result, state} = Hangman.Game.guess(state, letter)
    {:reply, result, state}
  end
end
