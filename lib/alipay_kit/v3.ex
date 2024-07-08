defmodule AlipayKit.V3 do
  @moduledoc """
  A kit for Alipay OpenAPI V3.

  ## References

    * [支付宝 V3 协议](https://opendocs.alipay.com/open-v3/053sd1)

  """
  @sign_request_opts_definition NimbleOptions.new!(
                                  app_id: [
                                    type: :string,
                                    required: true
                                  ],
                                  private_key: [
                                    type: :string,
                                    required: true
                                  ],
                                  sign_type: [
                                    type: {:in, [:SHA256withRSA, :SM3withSM2]},
                                    default: :SHA256withRSA
                                  ],
                                  app_cert_sn: [
                                    type: :string
                                  ],
                                  app_auth_token: [
                                    type: :string
                                  ],
                                  alipay_root_cert_sn: [
                                    type: :string
                                  ],
                                  nonce: [
                                    type: :string
                                  ],
                                  timestamp: [
                                    type: :string
                                  ]
                                )

  @doc """
  Signs a request.

  ## References

    * [支付宝 v3 协议 - 签名规则](https://opendocs.alipay.com/open-v3/054q58)

  """
  def sign_request!(%HTTPSpec.Request{} = request, opts) do
    opts = NimbleOptions.validate!(opts, @sign_request_opts_definition)

    # add authorization header
    sign_type = Keyword.fetch!(opts, :sign_type)
    auth_string = build_auth_string(opts)
    string_to_sign = build_string_to_sign(request, auth_string, opts)
    signature = sign(string_to_sign, opts)
    authorization = "ALIPAY-#{sign_type} #{auth_string},sign=#{signature}"
    request = HTTPSpec.Request.put_header(request, "authorization", authorization)

    # add alipay-root-cert-sn header
    alipay_root_cert_sn = Keyword.get(opts, :alipay_root_cert_sn)

    if alipay_root_cert_sn,
      do: HTTPSpec.Request.put_header(request, "alipay-root-cert-sn", alipay_root_cert_sn),
      else: request
  end

  defp build_auth_string(opts) do
    app_id = Keyword.fetch!(opts, :app_id)
    app_cert_sn = Keyword.get(opts, :app_cert_sn, nil)
    nonce = Keyword.get_lazy(opts, :nonce, fn -> random_string() end)
    timestamp = Keyword.get_lazy(opts, :timestamp, fn -> timestamp() end)

    [
      app_id: app_id,
      app_cert_sn: app_cert_sn,
      nonce: nonce,
      timestamp: timestamp
    ]
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.map_join(",", fn {k, v} -> "#{k}=#{v}" end)
  end

  defp build_string_to_sign(request, auth_string, opts) do
    app_auth_token = Keyword.get(opts, :app_auth_token, nil)

    [
      auth_string,
      build_http_request_method(request),
      build_http_request_url(request),
      build_http_request_body(request),
      app_auth_token
    ]
    |> Enum.reject(fn v -> v == nil end)
    |> Enum.map_join("", fn v -> "#{v}\n" end)
  end

  defp sign(string_to_sign, opts) do
    sign_type = Keyword.fetch!(opts, :sign_type)
    private_key = Keyword.fetch!(opts, :private_key)
    do_sign(sign_type, private_key, string_to_sign)
  end

  defp do_sign(:SHA256withRSA, private_key, string_to_sign) do
    [rsa_entry] = :public_key.pem_decode(private_key)
    key = :public_key.pem_entry_decode(rsa_entry)
    string_to_sign |> :public_key.sign(:sha256, key) |> Base.encode64()
  end

  defp do_sign(:SM3withSM2, _private_key, _string_to_sign) do
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
