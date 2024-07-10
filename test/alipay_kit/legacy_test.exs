defmodule AlipayKit.LegacyTest do
  use ExUnit.Case
  alias AlipayKit.Legacy

  setup do
    # These information comes from sandbox environment.
    # Don't waste your time on this, crackers.

    endpoint = "https://openapi-sandbox.dl.alipaydev.com/gateway.do"

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
      endpoint: endpoint,
      app_id: app_id,
      app_private_key: app_private_key,
      alipay_public_key: alipay_public_key
    }
  end

  describe "sign_params!/2" do
    test "works", %{app_id: app_id, app_private_key: app_private_key} do
      expected_signed_params =
        "app_id=9021000139603846&biz_content=%7B%22out_trade_no%22%3A%2270501111111S001111119%22%7D&charset=UTF-8&format=JSON&method=alipay.trade.query&sign_type=RSA2&timestamp=2024-07-09+12%3A06%3A08&version=1.0&sign=CZDOSANYS%2BIxz1FrW6NQ0Jwlr%2B1DxQ6pvaL7zo0vdqa4%2FrP0TT2fWefQu2T9VKsyPovxuS7gl9xCj6pRPgb0MrWRE8%2FOLzdKAEMcib%2Fzoq0avusxStGQbxRriI%2BhXxhKz%2FAev6Hzs8q%2FaD%2BSudVSlRh%2Fb2Mc7r%2FY0Qn1im0sayau2YF%2B%2FxFEj7CuYMuTF8dXnExa%2FjMGWg0J7360UAmXujibVmNEnJVN%2Fowns7No7zMT49z5MYWJSNP%2FZOmvojxd%2F9jE96g5dTQEQDajgV%2BucImyWi4tZq6us4Fbm8lS4zForUZTa1DxYAr9yTAFHezJf1PDeQObomWUv%2B5tk5pIvQ%3D%3D"

      assert expected_signed_params ==
               Legacy.sign_params!(
                 %{
                   app_id: app_id,
                   method: "alipay.trade.query",
                   biz_content: %{
                     out_trade_no: "70501111111S001111119"
                   },
                   timestamp: "2024-07-09 12:06:08"
                 },
                 app_private_key: app_private_key
               )
    end
  end

  describe "verify_response/2" do
    test "returns :ok when everything's fine", %{alipay_public_key: alipay_public_key} do
      response =
        HTTPSpec.Response.new!(
          status: 200,
          # An example body extracted from the response of an `alipay.trade.query` request.
          body:
            "{\"alipay_trade_query_response\":{\"msg\":\"Business Failed\",\"code\":\"40004\",\"out_trade_no\":\"70501111111S001111120\",\"sub_msg\":\"交易不存在\",\"sub_code\":\"ACQ.TRADE_NOT_EXIST\",\"receipt_amount\":\"0.00\",\"point_amount\":\"0.00\",\"buyer_pay_amount\":\"0.00\",\"invoice_amount\":\"0.00\"},\"sign\":\"o6SzVq8LCPp5L5sP61B23QRrkZwjMGlTYojIK6r0wph11h7kbkHE1rgdYgFNRaLYmxqs7bGkFit65Uk2CtT2NaMe4SjydIZzvu8774RPv8GFeTg6PFvKOsb6HUgFWuGEd8DN0LJYJqQrg5QXV+G8FYwNw4Sx+pqSVjq3c9eVdb5dwPhObfBHjao2LKs3T19wZR4ZNp3clhZOknsuT72vkogI/3yTOLsc3U0fSTrlRXKP7p5X6hd7u9MIJk2w3obOAFHs++yUmS0QkhcdxgICzajf/Ppzy/ssL7OohJHbiHk8JaBeH6yBgxmNMzoyVP4fZs7W/ZUL9zJli0jh8dxPUg==\"}"
        )

      assert {:ok,
              %{
                "buyer_pay_amount" => "0.00",
                "code" => "40004",
                "invoice_amount" => "0.00",
                "msg" => "Business Failed",
                "out_trade_no" => "70501111111S001111120",
                "point_amount" => "0.00",
                "receipt_amount" => "0.00",
                "sub_code" => "ACQ.TRADE_NOT_EXIST",
                "sub_msg" => "交易不存在"
              }} ==
               Legacy.verify_response(response,
                 alipay_public_key: alipay_public_key,
                 sign_type: :RSA2
               )
    end

    test "returns {:error, :bad_response} when the response body is in bad format", %{
      alipay_public_key: alipay_public_key
    } do
      response =
        HTTPSpec.Response.new!(
          status: 200,
          # An example body extracted from the response of an `alipay.trade.query` request.
          # But, the order of the keys is adjusted.
          body:
            "{\"sign\":\"o6SzVq8LCPp5L5sP61B23QRrkZwjMGlTYojIK6r0wph11h7kbkHE1rgdYgFNRaLYmxqs7bGkFit65Uk2CtT2NaMe4SjydIZzvu8774RPv8GFeTg6PFvKOsb6HUgFWuGEd8DN0LJYJqQrg5QXV+G8FYwNw4Sx+pqSVjq3c9eVdb5dwPhObfBHjao2LKs3T19wZR4ZNp3clhZOknsuT72vkogI/3yTOLsc3U0fSTrlRXKP7p5X6hd7u9MIJk2w3obOAFHs++yUmS0QkhcdxgICzajf/Ppzy/ssL7OohJHbiHk8JaBeH6yBgxmNMzoyVP4fZs7W/ZUL9zJli0jh8dxPUg==\",\"alipay_trade_query_response\":{\"msg\":\"Business Failed\",\"code\":\"40004\",\"out_trade_no\":\"70501111111S001111120\",\"sub_msg\":\"交易不存在\",\"sub_code\":\"ACQ.TRADE_NOT_EXIST\",\"receipt_amount\":\"0.00\",\"point_amount\":\"0.00\",\"buyer_pay_amount\":\"0.00\",\"invoice_amount\":\"0.00\"}}"
        )

      assert {:error, :bad_response} ==
               Legacy.verify_response(response,
                 alipay_public_key: alipay_public_key,
                 sign_type: :RSA2
               )
    end

    test "returns {:error, :bad_signature} when the response body is cracked", %{
      alipay_public_key: alipay_public_key
    } do
      response =
        HTTPSpec.Response.new!(
          status: 200,
          # An example body extracted from the response of an `alipay.trade.query` request.
          # But, the data is modified a lit bit.
          body:
            "{\"alipay_trade_query_response\":{\"msg\":\"Business Success\",\"code\":\"40004\",\"out_trade_no\":\"70501111111S001111120\",\"sub_msg\":\"交易不存在\",\"sub_code\":\"ACQ.TRADE_NOT_EXIST\",\"receipt_amount\":\"0.00\",\"point_amount\":\"0.00\",\"buyer_pay_amount\":\"0.00\",\"invoice_amount\":\"0.00\"},\"sign\":\"o6SzVq8LCPp5L5sP61B23QRrkZwjMGlTYojIK6r0wph11h7kbkHE1rgdYgFNRaLYmxqs7bGkFit65Uk2CtT2NaMe4SjydIZzvu8774RPv8GFeTg6PFvKOsb6HUgFWuGEd8DN0LJYJqQrg5QXV+G8FYwNw4Sx+pqSVjq3c9eVdb5dwPhObfBHjao2LKs3T19wZR4ZNp3clhZOknsuT72vkogI/3yTOLsc3U0fSTrlRXKP7p5X6hd7u9MIJk2w3obOAFHs++yUmS0QkhcdxgICzajf/Ppzy/ssL7OohJHbiHk8JaBeH6yBgxmNMzoyVP4fZs7W/ZUL9zJli0jh8dxPUg==\"}"
        )

      assert {:error, :bad_signature} ==
               Legacy.verify_response(response,
                 alipay_public_key: alipay_public_key,
                 sign_type: :RSA2
               )
    end
  end

  describe "verify_notification/2" do
    # credo:disable-for-next-line
    # TODO: test it
  end

  describe "sends real requests" do
    @describetag external: true

    setup %{app_id: app_id, app_private_key: app_private_key} do
      signed_params =
        Legacy.sign_params!(
          %{
            app_id: app_id,
            method: "alipay.trade.query",
            biz_content: %{
              out_trade_no: "70501111111S001111120"
            }
          },
          app_private_key: app_private_key
        )

      %{signed_params: signed_params}
    end

    test "GET", %{
      endpoint: endpoint,
      signed_params: signed_params,
      alipay_public_key: alipay_public_key
    } do
      {:ok, %{status: status, body: body, headers: headers}} =
        Finch.build(:get, "#{endpoint}?#{signed_params}")
        |> Finch.request(MyFinch)

      response = HTTPSpec.Response.new!(status: status, body: body, headers: headers)

      assert {:ok, _} =
               AlipayKit.Legacy.verify_response(response,
                 alipay_public_key: alipay_public_key
               )
    end

    test "POST", %{
      endpoint: endpoint,
      signed_params: signed_params,
      alipay_public_key: alipay_public_key
    } do
      {:ok, %{status: status, body: body, headers: headers}} =
        Finch.build(
          :post,
          endpoint,
          [{"content-type", "application/x-www-form-urlencoded; charset=UTF-8"}],
          signed_params
        )
        |> Finch.request(MyFinch)

      response = HTTPSpec.Response.new!(status: status, body: body, headers: headers)

      assert {:ok, _} =
               AlipayKit.Legacy.verify_response(response,
                 alipay_public_key: alipay_public_key
               )
    end
  end
end
