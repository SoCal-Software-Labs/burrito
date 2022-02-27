defmodule OnlyOne.MixProject do
  use Mix.Project

  def project do
    [
      app: :only_one,
      releases: releases(),
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def releases do
    [
      example_cli_app: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos: [os: :darwin, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64],
            linux_musl: [os: :linux, cpu: :x86_64, libc: :musl],
            windows: [os: :windows, cpu: :x86_64]
          ],
          debug: Mix.env() != :prod,
          plugin: "./plugin/file_check.zig",
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {OnlyOne, []}
    ]
  end

  defp deps do
    [
      {:burrito, path: "../../"},
      {:evac, "~> 0.2.0"}
    ]
  end
end
