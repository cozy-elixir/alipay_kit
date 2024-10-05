defmodule AlipayKit.V3 do
  @moduledoc """
  A kit for Alipay OpenAPI V3.

  ## Endpoints

    * Production: `"https://openapi.alipay.com/v3"`
    * Sandbox: `"https://openapi-sandbox.dl.alipaydev.com/v3"`

  ## Methods for signing

  Alipay officially supports two methods:

    * Keys (密钥)
    * Certificates (证书)

  But, this module only supports **Keys** method for now.

  ## Explore available API

  Visit <https://open.alipay.com/api>.

  ## Usage

  ### Build a signed request and send it via an HTTP request

    1. build a `%HTTPSpec.Request{}`.
    2. sign the request with `sign_request!/2`.
    3. send the requset.

  When building the request, don't forget adding required headers:

  ```text
  Content-Type: application/json; charset=UTF-8
  Accept: application/json
  ```

  And it's better to add a header for request id:

  ```text
  alipay-request-id: <32 characters>
  ```

  ## More

  I don't want to repeat what the official documentation already covers. For
  more information, please refer to the following materials:

    * [支付宝 OpenAPI V3](https://opendocs.alipay.com/open-v3/053sd1)

  """
  @sign_request_opts_definition NimbleOptions.new!(
                                  app_id: [
                                    type: :string,
                                    required: true
                                  ],
                                  app_private_key: [
                                    type: :string,
                                    required: true
                                  ],
                                  sign_type: [
                                    type: {:in, [:SHA256withRSA, :SM3withSM2]},
                                    default: :SHA256withRSA
                                  ],
                                  nonce: [
                                    type: :string
                                  ],
                                  timestamp: [
                                    type: :string
                                  ]
                                )

  @verify_response_opts_definition NimbleOptions.new!(
                                     alipay_public_key: [
                                       type: :string,
                                       required: true
                                     ],
                                     sign_type: [
                                       type: {:in, [:SHA256withRSA, :SM3withSM2]},
                                       default: :SHA256withRSA
                                     ]
                                   )

  @type app_id :: String.t()
  @type nonce :: String.t()
  @type timestamp :: String.t()

  @typedoc """
  The app's RSA private key in PEM format, such as:

  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEowIBAAKCAQEAlHcsKzSFSoYkHionHPwocwlgpX1iS9Fg+ZadVZMHiKrXvHUW
  <truncated>
  -----END RSA PRIVATE KEY-----
  ```

  or:

  ```
  -----BEGIN PRIVATE KEY-----
  MIIEowIBAAKCAQEAlHcsKzSFSoYkHionHPwocwlgpX1iS9Fg+ZadVZMHiKrXvHUW
  <truncated>
  -----END PRIVATE KEY-----
  ```
  """
  @type app_private_key :: String.t()

  @typedoc """
  The Alipay's public key in PEM format, such as:

  ```
  -----BEGIN PUBLIC KEY-----
  MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlHcsKzSFSoYkHionHPwo
  <truncated>
  -----END PUBLIC KEY-----
  ```
  """
  @type alipay_public_key :: String.t()

  @type sign_type :: :SHA256withRSA | :SM3withSM2

  @type sign_request_opt ::
          {:app_id, app_id()}
          | {:app_private_key, app_private_key()}
          | {:sign_type, sign_type()}
          | {:nonce, nonce()}
          | {:timestamp, timestamp()}

  @type sign_request_opts :: [sign_request_opt()]

  @type verify_response_opt ::
          {:alipay_public_key, alipay_public_key()} | {:sign_type, sign_type()}
  @type verify_response_opts :: [verify_response_opt()]

  @doc """
  Signs a request.

  ## Examples

  ## References

    * [支付宝 OpenAPI V3 - 签名规则](https://opendocs.alipay.com/open-v3/054q58)

  """
  @spec sign_request!(HTTPSpec.Request.t(), sign_request_opts()) :: HTTPSpec.Request.t()
  def sign_request!(%HTTPSpec.Request{} = request, opts) do
    opts = NimbleOptions.validate!(opts, @sign_request_opts_definition)

    # add authorization header
    sign_type = Keyword.fetch!(opts, :sign_type)
    auth_string = build_auth_string(opts)
    string_to_sign = build_string_to_sign(request, auth_string)
    signature = sign(string_to_sign, opts)
    authorization = "ALIPAY-#{sign_type} #{auth_string},sign=#{signature}"
    HTTPSpec.Request.put_header(request, "authorization", authorization)
  end

  @doc """
  Verifies a response returned by Alipay, and returns the verified and decoded body.

  ## References

    * [支付宝 OpenAPI V3 - 验签规则](https://opendocs.alipay.com/open-v3/054d0z)

  """
  @spec verify_response(HTTPSpec.Response.t(), verify_response_opts()) ::
          :ok | {:error, :bad_response | :bad_signature}
  def verify_response(%HTTPSpec.Response{} = response, opts) do
    opts = NimbleOptions.validate!(opts, @verify_response_opts_definition)
    alipay_public_key = Keyword.fetch!(opts, :alipay_public_key)
    sign_type = Keyword.fetch!(opts, :sign_type)

    with [timestamp] <- HTTPSpec.Response.get_header(response, "alipay-timestamp"),
         [nonce] <- HTTPSpec.Response.get_header(response, "alipay-nonce"),
         [signature] <- HTTPSpec.Response.get_header(response, "alipay-signature") do
      string_to_sign =
        Enum.map_join(
          [timestamp, nonce, response.body],
          "",
          fn v -> "#{v}\n" end
        )

      if verify?(sign_type, string_to_sign, alipay_public_key, signature),
        do: :ok,
        else: {:error, :bad_signature}
    else
      _ ->
        {:error, :bad_response}
    end
  end

  defp build_auth_string(opts) do
    app_id = Keyword.fetch!(opts, :app_id)
    nonce = Keyword.get_lazy(opts, :nonce, fn -> random_string() end)
    timestamp = Keyword.get_lazy(opts, :timestamp, fn -> timestamp() end)

    [
      app_id: app_id,
      nonce: nonce,
      timestamp: timestamp
    ]
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.map_join(",", fn {k, v} -> "#{k}=#{v}" end)
  end

  defp build_string_to_sign(request, auth_string) do
    [
      auth_string,
      build_http_request_method(request),
      build_http_request_url(request),
      build_http_request_body(request)
    ]
    |> Enum.reject(fn v -> v == nil end)
    |> Enum.map_join("", fn v -> "#{v}\n" end)
  end

  defp sign(string_to_sign, opts) do
    sign_type = Keyword.fetch!(opts, :sign_type)
    app_private_key = Keyword.fetch!(opts, :app_private_key)
    do_sign(sign_type, app_private_key, string_to_sign)
  end

  defp do_sign(:SHA256withRSA, private_key, string_to_sign) do
    [rsa_entry] = :public_key.pem_decode(private_key)
    key = :public_key.pem_entry_decode(rsa_entry)
    string_to_sign |> :public_key.sign(:sha256, key) |> Base.encode64()
  end

  defp do_sign(:SM3withSM2, _private_key, _string_to_sign) do
    raise RuntimeError, "not implemented"
  end

  defp verify?(:SHA256withRSA, string_to_sign, public_key, signature) do
    try do
      signature = Base.decode64!(signature)
      [rsa_entry] = :public_key.pem_decode(public_key)
      key = :public_key.pem_entry_decode(rsa_entry)
      :public_key.verify(string_to_sign, :sha256, signature, key)
    rescue
      _ -> false
    end
  end

  defp verify?(:SM3withSM2, _string_to_sign, _public_key, _signature) do
    raise RuntimeError, "not implemented"
  end

  defp build_http_request_method(request) do
    request.method |> to_string() |> String.upcase()
  end

  defp build_http_request_url(request) do
    if request.query in ["", nil],
      do: request.path,
      else: "#{request.path}?#{request.query}"
  end

  defp build_http_request_body(request) do
    body = request.body
    if body == "", do: nil, else: body
  end

  defp random_string do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  defp timestamp do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end
end
