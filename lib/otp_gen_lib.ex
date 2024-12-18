defmodule OtpGenLib do
  @moduledoc """
    A module for OTP (One-Time Password) management implemented as a GenServer.

    The `OtpGenLib` module provides functionality to:
    - Generate a 6-digit OTP for a given key.
    - Verify an OTP for correctness.
    - Automatically expire OTPs after a configured timeout.
    - Log OTP expiration events for debugging or monitoring.

    This module is designed for secure, temporary authentication workflows where OTPs are used for user verification or transaction approvals.

    ## Features
    - **OTP Generation**: Generates a random 6-digit OTP and stores it in memory after hashing it for security.
    - **OTP Verification**: Verifies user-provided OTPs against the stored hash.
    - **Automatic Expiry**: OTPs automatically expire after a configurable timeout (default: 30 seconds).
    - **Concurrency**: Leverages GenServer for thread-safe, stateful operations.
    - **Logging**: Logs OTP expiration events using `Logger`.

    ## Configuration
    - `@otp_expiry`: Configurable OTP expiration time in milliseconds (default: 30,000 ms or 30 seconds).

    ## Usage
    Start the GenServer and call the API functions to generate and verify OTPs.

    ### Example:
    elixir
    {:ok, _pid} = OtpGenLib.start_link(%{})

    # Generate an OTP for a key (e.g., user email or ID)
    otp = OtpGenLib.generate_otp("user@example.com")
    IO.inspect(otp) # Output: "123456"

    # Verify the OTP
    result = OtpGenLib.verify_otp("user@example.com", otp)
    IO.inspect(result) # Output: {:ok, true}

    # Wait for OTP expiration and attempt verification again
    :timer.sleep(30_000)
    result = OtpGenLib.verify_otp("user@example.com", otp)
    IO.inspect(result) # Output: {:ok, false}
  """
  use GenServer
  require Logger
  @otp_expiry 30_000

  def init(_args) do
    {:ok, %{}}
  end

  @doc """
  Starts the `OtpGenLib` GenServer.

  ## Returns
  - `{:ok, pid()}`: If the GenServer starts successfully.
  - `{:error, any()}`: If there is an error during startup.
  """
  @spec start_link(any()) :: {:ok, pid()} | {:error, any()}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Generates a 6-digit OTP for a given key.

  ## Parameters
  - `key`: A unique identifier (e.g., user email or ID).

  ## Returns
  - `String.t()`: The generated OTP if successful.
  - `{:error, :otp_already_exists}`: If an OTP for the given key already exists.
  """
  @spec generate_otp(key :: any()) :: String.t() | {:error, :otp_already_exists}
  def generate_otp(key) do
    GenServer.call(__MODULE__, {:generate, key})
  end

  @doc """
  Verifies the provided OTP against the stored hash for a given key.

  ## Parameters
  - `key`: The unique identifier associated with the OTP.
  - `inp_otp`: The OTP input provided by the user.

  ## Returns
  - `{:ok, true}`: If the OTP is valid.
  - `{:ok, false}`: If the OTP is invalid or expired.
  """
  @spec verify_otp(key :: any(), inp_otp :: String.t()) :: {:ok, boolean()} | {:error, atom()}
  def verify_otp(key, inp_otp) do
    GenServer.call(__MODULE__, {:verify?, key, inp_otp})
  end

  # Handles a GenServer call for verifying an OTP.
  # It hashes the input OTP and compares it with the stored hashed OTP for the given key.
  # If the OTP matches, it deletes the key from the state and returns `true`.
  # If the OTP does not match or the key does not exist, it returns `false`.
  @spec handle_call({:verify?, any(), String.t()}, GenServer.from(), map()) ::
          {:reply, boolean(), map()}
  def handle_call({:verify?, key, inp_otp}, _from, state) do
    hashed_otp = :crypto.hash(:sha256, inp_otp) |> Base.encode16()

    case Map.fetch(state, key) do
      {:ok, stored_otp} when stored_otp == hashed_otp ->
        {:reply, true, Map.delete(state, key)}

      {:ok, _stored_otp} ->
        {:reply, false, Map.delete(state, key)}

      :error ->
        {:reply, false, state}
    end
  end

  # Handles a GenServer call for generating a new OTP.
  # It ensures the key does not already exist in the state.
  # If the key is new, it generates a 6-digit OTP, hashes it, and stores it in the state.
  @spec handle_call({:generate, any()}, GenServer.from(), map()) ::
          {:reply, String.t(), map()} | {:reply, {:error, :otp_already_exists}, map()}

  def handle_call({:generate, key}, _from, state) do
    if Map.has_key?(state, key) do
      {:reply, {:error, :otp_already_exists}, state}
    else
      otp = 100_000 + :rand.uniform(999_999 - 100_000 + 1)
      Process.send_after(self(), {:expire, key}, @otp_expiry)
      stringotp = Integer.to_string(otp)
      hashed_otp = :crypto.hash(:sha256, stringotp) |> Base.encode16()
      state = Map.put(state, key, hashed_otp)
      {:reply, stringotp, state}
    end
  end

  # Handles a GenServer message to expire an OTP.
  # When an OTP expires, the key is removed from the state,
  # and an informational log is written for debugging or monitoring.
  @spec handle_info({:expire, any()}, map()) :: {:noreply, map()}

  def handle_info({:expire, key}, state) do
    Logger.info("OTP for key \"#{key}\" expired")
    {:noreply, Map.delete(state, key)}
  end
end
