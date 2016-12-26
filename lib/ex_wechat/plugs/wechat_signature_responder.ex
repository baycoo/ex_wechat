defmodule ExWechat.Plugs.WechatSignatureResponder do
  @moduledoc """
  Wechat server signature checker.
  Makesure the message is come from wechat server.
  http://mp.weixin.qq.com/wiki/8/f9a0b8382e0b77d87b3bcc1ce6fbc104.html
  """

  import Plug.Conn
  import ExWechat.Helpers.CryptoHelper

  def init(options) do
    options
  end

  def call(conn = %Plug.Conn{params: params}, options) do
    api = options[:api] || ExWechat
    case params do
      %{"signature" => _, "timestamp" => _, "nonce" => _} ->
        assign(conn, :signature, verify(api, params))
      _ ->
        assign(conn, :signature, false)
    end
  end

  defp verify(api, %{"signature" => signature,
        "timestamp" => timestamp, "nonce" => nonce}) do
    wechat_hash_equal?([token(api), timestamp, nonce], signature)
  end

  defp token(api) do
    apply(api, :token, [])
  end
end
