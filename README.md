# OtpGenLib

**OtpGenLib** is a library built for generating and verifying One-Time Passwords (OTPs) using Elixir. The OTPs are securely hashed and expire after a configured timeout. This library is designed for authentication workflows where OTPs are required for user verification or transaction approvals.

## Features

- **OTP Generation**: Generates a random 6-digit OTP for a given key (e.g., user email or ID).
- **OTP Verification**: Verifies the user-provided OTP against the stored OTP hash.
- **OTP Expiry**: OTPs automatically expire after a configured timeout (default: 30 seconds).
- **Concurrency**: Utilizes Elixir's GenServer for stateful, thread-safe operations.
- **Logging**: Logs OTP expiration events for monitoring and debugging purposes.

## Installation

To add this library to your project, you can use the following in your `mix.exs` file:

```elixir
defp deps do
  [
    {:otp_gen_lib, git: "https://github.com/rathi-abhinav/OtpGenLib.git"}
  ]
end
```
*normal_app_module.ex is just to see how it can be used.
