defmodule Hangman.GameServer do
  use GenServer

  @time_until_restart 3000 # In milliseconds.

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

  # Restarts the game after a certain amount of time.
  defp restart, do: Process.send_after(self(), :restart, @time_until_restart)

  ## Server Callbacks

  def init(:ok), do: {:ok, Hangman.Game.initial_state}

  # Get the state as a nicely formatted string.
  def handle_call(:get_state, _from, state) do
    {:reply, Hangman.Game.scrubbed_state(state), state}
  end

  # Update the game state with a new guess.
  def handle_call({:guess, letter}, _from, state) do
    {result, state} = Hangman.Game.guess(state, letter)
    unless state.progress == :in_progress, do: restart

    {:reply, result, state}
  end

  # Restart the game (if it is finished).
  def handle_info(:restart, state) do
    if state.progress == :in_progress do
      {:noreply, state}
    else
      {:noreply, Hangman.Game.initial_state}
    end
  end
end
