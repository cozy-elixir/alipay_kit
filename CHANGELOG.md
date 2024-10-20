# Changelog

## v1.0.0

- upgrade http_spec to v3.0.0

## v0.3.0

- change return value of `AlipayKit.V3.verify_response/2` from `{:ok, map()} | {:error, :bad_response | :bad_signature}` to `:ok | {:error, :bad_response | :bad_signature}`
