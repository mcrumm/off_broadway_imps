defmodule OffBroadway.Imps.MixProject do
  use Mix.Project

  def project do
    [
      app: :off_broadway_imps,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:broadway, "~> 0.6.0-rc.0"},
      {:ex_doc, "~> 0.21", only: :docs},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
