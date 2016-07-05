defmodule DarianCalendar.Mixfile do
  use Mix.Project

  def project do
    [app: :darian_calendar,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: "Package to convert Terrestrian date into Martian date according the Darian Calendar.",
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp package do
    [# These are the default files included in the package
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Davide Aversa"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/THeK3nger/darian-calendar-elixir"}]
  end
end
