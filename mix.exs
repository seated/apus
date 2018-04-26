defmodule Apus.MixProject do
  use Mix.Project

  def project do
    [
      app: :apus,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Apus.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_twilio, "~> 0.6.0"},
      {:excoveralls, "~> 0.8.1", [only: :test]},
      {:exvcr, "~> 0.10.2", only: :test}
    ]
  end
end
