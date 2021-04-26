defmodule MyBox.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.10", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: ["format", "credo"]
    ]
  end
end
