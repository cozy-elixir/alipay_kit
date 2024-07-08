defmodule AlipayKit.MixProject do
  use Mix.Project

  def project do
    [
      app: :alipay_kit,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :public_key]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:http_spec, "~> 1.1"},
      {:nimble_options, "~> 1.0"},
    ]
  end
end
