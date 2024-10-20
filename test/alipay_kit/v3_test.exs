defmodule AlipayKit.V3Test do
  use ExUnit.Case

  alias AlipayKit.V3

  setup do
    # These information comes from sandbox environment.
    # Don't waste your time on this, crackers.

    host = "openapi-sandbox.dl.alipaydev.com"

    app_id = "9021000139603846"

    app_private_key = """
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCKgAtfsAnc5wob8Ephb00KtpOuCym93IycIyylizVbAvUETBf8SjoWBzhfVfAI4Dsj3ceZGlJZ4by7lwmwgkrKekAGGcmX7iHiMLNj7VPf8q4WIfYQBRVTUGJj2iiHNMlweWXxipnBqBYz4ewfayZOoGMtUi9gGSkDbptSBV/1LuGw8YUtrqL/8U47maNPqrBjHQLFnqzO9n5IGaVIHelI9nysnJqB4GbAowE+lsNF1kKc8dz7CkfnDCUwd6KUsV+nWPQBlZl5WXYtglLE4h1yWfwdQJuwCw/39uQMQ5taX/JcL8xHof7tpphc0CT38Zdij9UbG+lF4xjRnPcpDkz7AgMBAAECggEAWci6FtTy/95SwlvajCFwCzLit6AK9kbkbE+tIMAG3bIkDh4aKnYgA6m4lK0MR2S9Ufny68CRhCz/gYhfQqqkO3BW0t2ivzgjhRNXJ79xcStMSZLIhggVlAX3Uo3ZWhURRTWdraDRHiaOBiI+RPvcQHpe8MFnbt/Ao7XvQJO1aiZ9fiTG5jRR7sYk+htsaHMBzG//ks8AGdPY853LT2O2toaVDXI8rKijpXLR3ow0iIZMZqvtOgyNY7FbdEijJf59plf6olaODh3bRI1nTaWjxeBp1dcVyZGfX2DXWTQ1KCYAmByY0ianCPh7PBrWKFpVk1u8uXNJRnWjAiBlSg+kwQKBgQDSxeYNUvnvqA8mPEeDogRDfLa0aLijDAWj9aIrQXgc18FMtJ6PGgpAN2P+kk8Go1FMqZE/1nWtPSXoQzX9A0tdwIhxzi7C7J3+bg9w5/L5oPgHvQU6XuwsnRPy3k+Q/TMxbQBuGS90ccWNKwaDBKc7m38XhIoB+xdL4Y/kPah0YQKBgQCoOBTImSU5C8dnYTSFyjQDx52jv2JtIbHQURae5uFX8NRSS/VIU1wFTE5NOF0971wMB2SE4j1FjL+vWaIiCssjXn4GBav/iclJzkemKRe+iRqQeZtBsLcYtlMUynXXznr0x0OPbj6FNSvBLYVia7RHJcltKysn2LgKIryIUIt+2wKBgQCYn3TWcR9KywctSLkAOHGd7NDgEnSgnDP5ZgToDaBMQm9We/PU66ZAmdtum8NdqyVTvfXPpBvSNlUcuo59h8UrPh+PSR3TSEOf2VKVD2CCIm14LQd8HQAnzhaD5zb2ZmKLh8Kn9tTGHRxP/LfaZ6QxJYgCH5dPl+JmsA7h10QEAQKBgH5STtksl9U00TMCvexSIalM90YF7CXDjcG/gtskyce+I9MBE1qSrqGT4aD/WJWv71FhI8zeD+Dwhulox+YEcPNIfB6Nl9G3aJ6x9wACD8CXOImRqFM2HujB0bXlK4U5mv/Buyw0P2LMwOS6CFYWRzS+XXpLVob/qYSC/UzoHzjNAoGAaa6P8iIoPbmKq15sB1Y3RtgTGjPuutpDyjt1z5d2ALxNrzGHZS8S4Stag7JDhYRByGefjZtANEauAxjtAjrQBBPzJN298wty6C2PTQ6FaLn+mnXF+9SVMTXNqefrXM0rWA5d7zjoVHEn5V2za4bXBCLElC6Y9DmZ6iIxIBsRyjc=
    -----END PRIVATE KEY-----
    """

    alipay_public_key = """
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqF8IdlfMMFT5IIyWhQ4tvwC1Z6L7Dl346kj494urfI99Sx+faC2PJF0qDwAKhgHYj1s8K3oAFcK6hLOfPAUM7xyVH/+xaYAbcxSNaCbFy9nWQ2O8YkyK9CSHey+w+K0cmqEBkd7Qhh9EYPECORMg5T7hrzwWUM/DX2wNiLXkHNS28Hv7U0EfIOFyXYM/ky/gznkAJCGujCPkSCLs8LeeKKKR3k2E52RFEd9cG01IsQ+7fqDcgKrXNYtrxEGaDOiyLSmXA2nzkKcR1VTizv69yzIBl15rWwBvRDs9nByEMhL+QmTVUmxfz/MLXzY4Xc2KoYAHAHElicFq+CN1TM+JCQIDAQAB
    -----END PUBLIC KEY-----
    """

    %{
      host: host,
      app_id: app_id,
      app_private_key: app_private_key,
      alipay_public_key: alipay_public_key
    }
  end

  describe "sign_request!/2" do
    test "works", %{
      host: host,
      app_id: app_id,
      app_private_key: app_private_key
    } do
      request =
        HTTPSpec.Request.new!(
          scheme: :https,
          host: host,
          port: 443,
          method: :post,
          path: "/v3/alipay/trade/query",
          headers: [
            {"content-type", "application/json; charset=UTF-8"},
            {"accept", "application/json"}
          ],
          body: json_encode!(%{out_trade_no: "70501111111S001111120"})
        )

      assert HTTPSpec.Request.new!(%{
               method: :post,
               scheme: :https,
               host: "openapi-sandbox.dl.alipaydev.com",
               port: 443,
               path: "/v3/alipay/trade/query",
               query: nil,
               fragment: nil,
               headers: [
                 {"content-type", "application/json; charset=UTF-8"},
                 {"accept", "application/json"},
                 {"authorization",
                  "ALIPAY-SHA256withRSA app_id=9021000139603846,nonce=517bbe132c0b8634b0d2f3b8c6b4c3d0,timestamp=1720580056525,sign=NcoqUaYawgSBAj3Yy41Sm9W9EZodAin5K8tC8Lvftk2D3rmlYOUFV5klEKleSD5uHb8GgMEeysCg2RIedJW9rYpA3O2cpRfy4bmXop674fcO0Y98RNyb2u+yPDzX84dmhsAxK/x2s8mj43az1/PUbNXHEpxpsu9LUW9dd5Lrkjo7vD6xuE3lyj35x7yA2wkShV7bJTVCCAFc9CxfIvSntaWNroy2TmuG9Z/GWVzcwEUVuajFOVfMnRcg/XxY1yVfa9o9wW3sW8Djt/7gfkqF+vtXgl477zxMNGEF8mdTbb3rPKusYrOSQYFVXiiyVFFCBcGas4vAa69HFn7EIXrZ/g=="}
               ],
               body: "{\"out_trade_no\":\"70501111111S001111120\"}"
             }) ==
               V3.sign_request!(request,
                 app_id: app_id,
                 app_private_key: app_private_key,
                 nonce: "517bbe132c0b8634b0d2f3b8c6b4c3d0",
                 timestamp: "1720580056525"
               )
    end
  end

  describe "verify_response/2" do
    test "works", %{alipay_public_key: alipay_public_key} do
      response =
        HTTPSpec.Response.new!(%{
          status: 400,
          body:
            "{\"out_trade_no\":\"70501111111S001111120\",\"code\":\"ACQ.TRADE_NOT_EXIST\",\"receipt_amount\":\"0.00\",\"message\":\"交易不存在\",\"point_amount\":\"0.00\",\"buyer_pay_amount\":\"0.00\",\"invoice_amount\":\"0.00\"}",
          headers: [
            {"server", "Tengine/2.1.0"},
            {"date", "Wed, 10 Jul 2024 02:59:35 GMT"},
            {"content-type", "application/json;charset=UTF-8"},
            {"content-length", "193"},
            {"connection", "keep-alive"},
            {"set-cookie", "JSESSIONID=FA5E427D30AFC9E2BAB78529EC3B9406; Path=/; HttpOnly"},
            {"alipay-trace-id", "060063f4172058037584134747918"},
            {"gateway_route_forward_type", "rpc_invoke_route"},
            {"alipay-nonce", "d5553f1d2304d354784457f7f6a3cfb2"},
            {"alipay-timestamp", "1720580375932"},
            {"alipay-signature",
             "Tp67Z5XBikhmF28kMBVR/OCFn+mqnlqnsCudUGS/hlZiV1j1CXkr0j4QENrUfm2m993iSGSZESoAOPCasp9XppQy4PKQsNE+vG840HFLA7eGTKWjzNVs3FO/JozNQlnm7oZcDPP16scvAF5ArmKUX571sv642kfZ3OZupVktye2reKiEUQQOxa7PJKlsei8mcjeT++DARR6wwyVNcM+WniHDOB1n9EW+scz9ROtkgsd56D0vgVaqFqmyIlkwqRpq6XF9lyf0nuFXAvQW7z6nlXwIZCkpu1kGMzlT48FuI66BPaNJWRM7/Q6eZoyNL+kBXFC06kMUg3XZh9eeXQj1VA=="},
            {"via", "spanner-13.cz01a.test.alipay.net[400],6.0.99.244:80[400]"}
          ]
        })

      assert :ok = V3.verify_response(response, alipay_public_key: alipay_public_key)

      assert {:ok,
              %{
                "buyer_pay_amount" => "0.00",
                "code" => "ACQ.TRADE_NOT_EXIST",
                "invoice_amount" => "0.00",
                "message" => "交易不存在",
                "out_trade_no" => "70501111111S001111120",
                "point_amount" => "0.00",
                "receipt_amount" => "0.00"
              }} = JXON.decode(response.body)
    end
  end

  describe "sends real requests" do
    @describetag external: true

    test "POST", %{
      host: host,
      app_id: app_id,
      app_private_key: app_private_key,
      alipay_public_key: alipay_public_key
    } do
      request =
        HTTPSpec.Request.new!(
          scheme: :https,
          host: host,
          port: 443,
          method: :post,
          path: "/v3/alipay/trade/query",
          headers: [
            {"content-type", "application/json; charset=UTF-8"},
            {"accept", "application/json"}
          ],
          body: json_encode!(%{out_trade_no: "70501111111S001111120"})
        )

      request =
        V3.sign_request!(request, app_id: app_id, app_private_key: app_private_key)

      {:ok, %{status: status, body: body, headers: headers}} =
        Finch.build(
          request.method,
          HTTPSpec.Request.build_url(request),
          request.headers,
          request.body
        )
        |> Finch.request(MyFinch)

      response =
        HTTPSpec.Response.new!(
          status: status,
          body: body,
          headers: headers
        )

      assert :ok = V3.verify_response(response, alipay_public_key: alipay_public_key)
    end
  end

  defp json_encode!(term) do
    {:ok, binary} = JXON.encode(term)
    binary
  end
end
