defmodule OtpGenLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :otp_gen_lib,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A reusable library for generating and verifying OTPs",
      package: package(),
      source_url: "https://github.com/rathi-abhinav/otp_gen_lib"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [
      name: "otp_gen_lib",
      maintainers: ["Abhinav Rathi"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rathi-abhinav/otp_gen_lib"}
    ]
  end
end
