defmodule OtpGenLibTest do
  use ExUnit.Case
  doctest OtpGenLib

  setup do
    {:ok, pid} = OtpGenLib.start_link(0)

    # Ensure the GenServer is terminated after each test
    on_exit(fn -> Process.exit(pid, :normal) end)

    {:ok, pid: pid}
  end

  test "start_link/1 starts the GenServer" do
    # Test if the GenServer starts successfully when it's not already started
    assert {:error, {:already_started, _pid}} = OtpGenLib.start_link(1)
  end

  test "init/1 initializes the GenServer" do
    # Test if the GenServer initializes the state correctly
    assert OtpGenLib.init(1) == {:ok, %{}}
  end

  test "generate_otp/1 generates an OTP" do
    # Test if generating an OTP works for a given key
    otp = OtpGenLib.generate_otp("a")
    assert String.length(otp) == 6
  end

  test "generate_otp/1 can generate different OTPs for different keys" do
    # Test if OTPs for different keys are different
    otp_a = OtpGenLib.generate_otp("a")
    otp_b = OtpGenLib.generate_otp("b")
    otp_c = OtpGenLib.generate_otp("c")

    assert otp_a != otp_b
    assert otp_b != otp_c
    assert otp_a != otp_c
  end

  test "verify_otp/2 checks correctness" do
    # Generate OTPs
    otp_a = OtpGenLib.generate_otp("a")
    otp_b = OtpGenLib.generate_otp("b")
    otp_c = OtpGenLib.generate_otp("c")

    # Verify correct OTPs
    assert true == OtpGenLib.verify_otp("b", otp_b)
    assert true == OtpGenLib.verify_otp("c", otp_c)
    assert true == OtpGenLib.verify_otp("a", otp_a)

    # Verify incorrect OTPs
    assert false == OtpGenLib.verify_otp("b", otp_a)
    assert false == OtpGenLib.verify_otp("a", otp_b)
    assert false == OtpGenLib.verify_otp("a", "invalid_otp")
  end

  test "verify_otp/2 after OTP expiration" do
    # Generate OTP with a short expiration time for faster testing
    otp_a = OtpGenLib.generate_otp("a")

    # Sleep for a shorter period (e.g., 1 second) to test expiration quickly
    :timer.sleep(1_000)

    # Inspect values to debug
    IO.inspect(OtpGenLib.verify_otp("a", otp_a))

    # Try verifying after expiration
    assert false == OtpGenLib.verify_otp("a", otp_a)
  end

  test "generate_otp/1 prevents duplicate OTP generation" do
    # Generate OTP for a key
    _otp_a = OtpGenLib.generate_otp("a")

    # Try to generate OTP again for the same key
    assert {:error, :otp_already_exists} == OtpGenLib.generate_otp("a")
  end
end
