# Changelog

## 0.3.0-dev

- change return value of `AlipayKit.V3.verify_response/2` from `{:ok, map()} | {:error, :bad_response | :bad_signature}` to `:ok | {:error, :bad_response | :bad_signature}`
