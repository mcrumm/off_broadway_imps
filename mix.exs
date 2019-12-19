defmodule OffBroadway.Imps.MixProject do
  use Mix.Project

  def project do
    [
      app: :off_broadway_imps,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:broadway, github: "plataformatec/broadway"},
      {:ex_doc, "~> 0.21", only: :docs}
    ]
  end
end
