# AlipayKit

[![CI](https://github.com/cozy-elixir/alipay_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/cozy-elixir/alipay_kit/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/alipay_kit.svg)](https://hex.pm/packages/alipay_kit)

A kit for Alipay.

## Features

- Not tightly coupled with a specific HTTP client (Built on top of [http_spec](https://hex.pm/packages/http_spec))
- Only includes basic signing and signature verification functions

## Installation

Add `:alipay_kit` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:alipay_kit, <requirement>}
  ]
end
```

## Usage

For more information, see the [documentation](https://hexdocs.pm/alipay_kit).

## License

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
