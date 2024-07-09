defmodule AlipayKit.Legacy do
  @moduledoc """
  A kit for Alipay Legacy API.

  > Although the OpenAPI V3 is released, some features are still retained in
  > the legacy API.

  ## Endpoints

    * Production: `"https://openapi.alipay.com/gateway.do"`
    * Sandbox: `"https://openapi-sandbox.dl.alipaydev.com/gateway.do"`

  ## Methods for signing

  Alipay officially supports two methods:

    * Keys (密钥)
    * Certificates (证书)

  But, this module only supports **Keys** method for now.

  ## Explore available API

  Visit <https://open.alipay.com/api>.

  ## Usage

  ### Build signed params for mobile SDK

  Just build a signed params, and pass it to the mobile SDK.

  ### Build a signed params and send it via an HTTP request

    1. build a signed params with `sign_params!/2`.
    2. send the signed params to a particular endpoint:
       - with a POST request
       - or, with a GET request

  Assuming we use the Production environment, then sending a GET request should
  be like this:

  ```text
  GET /gateway.do?<signed_params> HTTP/1.1
  Host: openapi.alipay.com
  ```

  Sending a POST request should be like this:

  ```text
  POST /gateway.do HTTP/1.1
  Host: openapi.alipay.com
  Content-Type: application/x-www-form-urlencoded; charset=UTF-8

  <signed params>
  ```

  > #### Warning {: .warning}
  >
  > Don't miss the `Content-Type` header when sending POST request, or the Alipay
  > will sent a bad response back.

  ## References

    * [支付宝 Legacy API](https://opendocs.alipay.com/common/02nebq)

  """

  @sign_params_definition NimbleOptions.new!(
                            app_id: [
                              type: :string,
                              required: true
                            ],
                            method: [
                              type: :string,
                              required: true
                            ],
                            format: [
                              type: {:in, ["JSON"]},
                              default: "JSON"
                            ],
                            charset: [
                              type: {:in, ["UTF-8"]},
                              default: "UTF-8"
                            ],
                            sign_type: [
                              type: {:in, [:RSA2, :RSA]},
                              default: :RSA2
                            ],
                            timestamp: [
                              type: :string,
                              doc: """
                              * Format: YYYY-MM-DD hh:mm:ss
                              * Example: 2014-07-24 03:07:50
                              """
                            ],
                            version: [
                              type: {:in, ["1.0"]},
                              default: "1.0"
                            ],
                            notify_url: [
                              type: :string
                            ],
                            biz_content: [
                              type: :map,
                              default: %{}
                            ]
                          )

  @sign_opts_definition NimbleOptions.new!(
                          app_private_key: [
                            type: :string
                          ]
                        )

  @verify_response_opts_definition NimbleOptions.new!(
                                     alipay_public_key: [
                                       type: :string,
                                       required: true
                                     ],
                                     sign_type: [
                                       type: {:in, [:RSA2, :RSA]},
                                       default: :RSA2
                                     ]
                                   )

  @verify_notification_opts_definition NimbleOptions.new!(
                                         alipay_public_key: [
                                           type: :string,
                                           required: true
                                         ]
                                       )

  @type app_id :: String.t()
  @type method :: String.t()
  @type format :: String.t()
  @type charset :: String.t()
  @type sign_type :: :RSA2 | :RSA
  @type timestamp :: String.t()
  @type version :: String.t()
  @type notify_url :: String.t()
  @type biz_content :: map()

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

  @typedoc """
  The params will be signed.

  ## Limitations

    * `app_auth_token` is not supported.

  """
  @type sign_params :: %{
          :app_id => app_id(),
          :method => method(),
          optional(:format) => format(),
          optional(:charset) => charset(),
          optional(:sign_type) => sign_type(),
          optional(:timestamp) => timestamp(),
          optional(:version) => version(),
          optional(:notify_url) => notify_url(),
          optional(:biz_content) => biz_content()
        }

  @type sign_params_opt :: {:app_private_key, app_private_key()}
  @type sign_params_opts :: [sign_params_opt()]

  @type verify_response_opt ::
          {:alipay_public_key, alipay_public_key()} | {:sign_type, sign_type()}
  @type verify_response_opts :: [verify_response_opt()]

  @type verify_notification_opt ::
          {:alipay_public_key, alipay_public_key()}
  @type verify_notification_opts :: [verify_notification_opt()]

  @doc """
  Signs params.

  ## Examples

      params = %{
        app_id: "your app id",
        method: "alipay.trade.pay",
        biz_content: %{
          out_trade_no: "70501111111S001111119",
          total_amount: "9.00",
          subject: "Fresh air"
        }
      }

      opts = [app_private_key: "your app private key"]

      AlipayKit.Legacy.sign_params!(params, opts)

  ## References

    * [自行实现签名](https://opendocs.alipay.com/common/057k53)

  """
  @spec sign_params!(sign_params(), sign_params_opts()) :: String.t()
  def sign_params!(params, opts) when is_map(params) do
    params =
      params
      |> NimbleOptions.validate!(@sign_params_definition)
      |> sanitize_params()

    opts = NimbleOptions.validate!(opts, @sign_opts_definition)

    sign_type = Map.fetch!(params, :sign_type)
    private_key = Keyword.fetch!(opts, :app_private_key)
    string_to_sign = build_string_to_sign(params)
    signature = sign(sign_type, string_to_sign, private_key)

    params
    |> Map.put(:sign, signature)
    |> encode_params()
  end

  @doc """
  Verifies response returned by Alipay, and returns the verified `*_response`
  section of body.

  ## Examples

      // send a request to Alipay service, and get a response
      response = HTTPSpec.Response.build!([
        body: "...",
        // ...
      ])

      AlipayKit.Legacy.verify_response(response, [
        alipay_public_key: "your alipay public key"
      ])

  ## References

    * [自行实现验签](https://opendocs.alipay.com/common/02mse7)

  """
  @spec verify_response(HTTPSpec.Response.t(), verify_response_opts()) ::
          {:ok, map()} | {:error, :bad_format | :bad_signature}
  def verify_response(%HTTPSpec.Response{} = response, opts) do
    opts = NimbleOptions.validate!(opts, @verify_response_opts_definition)
    alipay_public_key = Keyword.fetch!(opts, :alipay_public_key)
    sign_type = Keyword.fetch!(opts, :sign_type)

    regex = ~r/"(?<key>\w+_response)":(?<content>.*),"sign":/

    with %{"key" => key, "content" => content} <- Regex.named_captures(regex, response.body),
         {:ok, body} <- json_decode(response.body) do
      signature = body["sign"]

      if verify?(sign_type, content, alipay_public_key, signature),
        do: {:ok, Map.fetch!(body, key)},
        else: {:error, :bad_signature}
    else
      _ -> {:error, :bad_format}
    end
  end

  @doc """
  Verifies notification request issued by Alipay, and returns the verified
  payload.

  ## Examples

      // send a request to Alipay service, and get a response
      request = HTTPSpec.Request.build!([
        query: "...",
        // ...
      ])

      AlipayKit.Legacy.verify_notification(request, [
        alipay_public_key: "your alipay public key"
      ])

  ## References

    * [自行实现验签](https://opendocs.alipay.com/common/02mse7)

  """
  @spec verify_notification(HTTPSpec.Request.t(), verify_notification_opts()) ::
          {:ok, map()} | {:error, :bad_signature}
  def verify_notification(%HTTPSpec.Request{} = request, opts) do
    opts = NimbleOptions.validate!(opts, @verify_notification_opts_definition)
    alipay_public_key = Keyword.fetch!(opts, :alipay_public_key)

    params = URI.decode_query(request.query, %{}, :rfc3986)
    sign_type = params |> Map.fetch!("sign_type") |> String.to_existing_atom()
    signature = Map.fetch!(params, "sign")

    payload =
      params
      |> Map.delete("sign")
      |> Map.delete("sign_type")

    string_to_sign = build_string_to_sign(payload)

    if verify?(sign_type, string_to_sign, alipay_public_key, signature),
      do: {:ok, payload},
      else: {:error, :bad_signature}
  end

  defp sanitize_params(params) do
    %{
      app_id: params.app_id,
      method: params.method,
      format: params.format,
      charset: params.charset,
      sign_type: params.sign_type,
      timestamp: params[:timestamp] || timestamp(),
      version: params.version,
      notify_url: params[:notify_url],
      biz_content: json_encode!(params.biz_content)
    }
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.into(%{})
  end

  defp build_string_to_sign(params) do
    params
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)
  end

  defp sign(sign_type, string_to_sign, private_key) do
    digest_type = get_digest_type(sign_type)
    [rsa_entry] = :public_key.pem_decode(private_key)
    key = :public_key.pem_entry_decode(rsa_entry)
    string_to_sign |> :public_key.sign(digest_type, key) |> Base.encode64()
  end

  defp verify?(sign_type, string_to_sign, public_key, signature) do
    try do
      digest_type = get_digest_type(sign_type)
      signature = Base.decode64!(signature)
      [rsa_entry] = :public_key.pem_decode(public_key)
      key = :public_key.pem_entry_decode(rsa_entry)
      :public_key.verify(string_to_sign, digest_type, signature, key)
    rescue
      _ -> false
    end
  end

  defp get_digest_type(:RSA2), do: :sha256
  defp get_digest_type(:RSA), do: :sha

  defp encode_params(params) do
    {signature, rest} = Map.pop!(params, :sign)

    [{:sign, signature} | Enum.sort_by(rest, fn {k, _v} -> k end, :desc)]
    |> Enum.reverse()
    |> URI.encode_query(:www_form)
  end

  defp json_encode!(term) do
    {:ok, binary} = JXON.encode(term)
    binary
  end

  defp json_decode(binary) when is_binary(binary) do
    JXON.decode(binary)
  end

  defp timestamp do
    NaiveDateTime.local_now() |> NaiveDateTime.to_string()
  end
end
