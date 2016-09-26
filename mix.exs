defmodule IEQBackhaul.Mixfile do
  use Mix.Project

  def project do
    [app: :ieq_gateway,
     version: "0.1.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [
      applications: [:logger, :nerves_uart],
      mod: {IEQGateway, []},
      env: [speed: 115200,
          tty: "/dev/ttyUSB0",
      ]
    ]
  end

  def description do
    """
    A Client for the RFM69-USB-Gateway and Indoor Air Quality Sensor
    """
  end

  def package do
    [
      name: :ieq_gateway,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Christopher Steven Coté"],
      licenses: ["Apache License 2.0"],
      links: %{"GitHub" => "https://github.com/NationalAssociationOfRealtors/ieq_gateway",
        "Docs" => "https://github.com/NationalAssociationOfRealtors/ieq_gateway"}
    ]
  end

  defp deps do
    [
      {:nerves_uart, "~> 0.1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
