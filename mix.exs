defmodule Burrito.MixProject do
  use Mix.Project

  def project do
    [
      app: :burrito,
      version: String.trim(File.read!("VERSION")),
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.1.0"},
      {:typed_struct, "~> 0.2.1"},
      {:jason, "~> 1.2"}
    ]
  end
end
