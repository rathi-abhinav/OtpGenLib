defmodule NormalAppModule do
  def start(_type, _args) do
    if Mix.env() != :test do
      otpservice()
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  def otpservice do
    {:ok, _pid} = OtpGenLib.start_link([])
    k = IO.gets("Enter a key: ") |> String.trim()
    IO.puts(OtpGenLib.generate_otp(k))
    IO.puts("OTP is valid for 30 seconds only")
    ik = IO.gets("Enter The Key: ") |> String.trim()
    inp_otp = IO.gets("Enter the OTP: ") |> String.trim()

    # IO.puts(OtpGenerator.verify_otp(ik, hashed_otp))
    if OtpGenLib.verify_otp(ik, inp_otp) == true do
      IO.puts("Validation Successful")
    else
      IO.puts("Invalid OTP and/or Key")
    end
  end

  def hello do
    :world
  end
end
