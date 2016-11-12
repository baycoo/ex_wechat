defmodule ExWechat.TestHelper.Http do
  use ExWechat.Base

  defmacro __using__(_) do
    quote do
      import :meck

      def expect_response(endpoint, path, params, body \\ "", result)
      def expect_response(endpoint, path, params, "", result) do
        expect(:hackney, :request, [{ [:get, "#{endpoint}#{path}?#{params_url(params)}", [], "", []],
                                      {:ok, 200, "headers", :client} }])
        expect(:hackney, :body, 1, {:ok, encode(result)})
      end
      def expect_response(endpoint, path, params, body, result) do
        expect(:hackney, :request, [{ [:post, "#{endpoint}#{path}?#{params_url(params)}", [], encode(body), []],
                                      {:ok, 200, "headers", :client} }])
        expect(:hackney, :body, 1, {:ok, encode(result)})
      end

      defp params_url(params) do
        params
        |> Enum.sort
        |> Enum.map(fn({key, value})->
             "#{key}=#{value}"
           end)
        |> Enum.join("&")
      end

      defp encode(body)
      defp encode(body) when is_binary(body), do: body
      defp encode(body) when is_map(body), do: Poison.encode!(body)
      defp encode(nil), do: ""
    end
  end
end
