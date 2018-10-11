defmodule ExNifcloud.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :ex_nifcloud,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: "Unofficial Nifcloud SDK for Elixir",
      deps: deps(),
      docs: [
        main: "ExNifcloud",
        source_ref: "v#{@version}",
        source_url: "https://github.com/kzmake/ex_nifcloud"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :hackney]
    ]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6", optional: true},
      {:ex_doc, "~> 0.16", only: [:dev, :test]},
      {:hackney, "1.6.3 or 1.6.5 or 1.7.1 or 1.8.6 or ~> 1.9", optional: true},
      {:poison, ">= 1.2.0", optional: true},
      {:jsx, "~> 2.8", optional: true},
      {:dialyze, "~> 0.2.0", only: [:dev, :test]},
      {:mox, "~> 0.3", only: :test},
      {:bypass, "~> 0.7", only: :test},
      {:configparser_ex, "~> 2.0", optional: true}
    ]
  end

  defp package do
    [
      description:
        "Unofficial Nifcloud SDK for Elixir",
      files: ["priv", "lib", "config", "mix.exs", "README*"],
      maintainers: ["Kazuki Iwata"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/kzmake/ex_nifcloud"
      }
    ]
  end
end
