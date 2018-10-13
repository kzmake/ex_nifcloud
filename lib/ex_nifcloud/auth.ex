defmodule ExNifcloud.Auth do

  alias ExNifcloud.Auth.Credentials
  alias ExNifcloud.Auth.Signatures

  @moduledoc false

  def body(http_method, url, body, config) do
    uri = url |> URI.parse
    path = uri.path |> URI.encode

    query = if uri.query, do: uri.query |> URI.decode_query, else: %{}
    data = Map.merge(query, body) |> Map.merge(%{
      AccessKeyId: config[:access_key_id],
      SignatureVersion: 2,
      SignatureMethod: "HmacSHA256",
      Timestamp: "2018-10-13T07:50:17Z", #DateTime.to_iso8601(DateTime.utc_now),
    })
    data_string = data |> Enum.to_list |> canonical_query_params |> URI.encode_query

    IO.inspect(data_string)
    signature = %{
      Signature: signature(http_method, uri.host, path, data_string, config[:secret_access_key]),
    }
    signed_body = data |> Map.merge(signature)

    {:ok, signed_body}
  end

  defp canonical_query_params(nil), do: []

  defp canonical_query_params(params) do
    params
    |> Enum.sort(fn {k1, _}, {k2, _} -> k1 < k2 end)
  end

  def signature(http_method, host, path, data, secret_key) do
    string_to_sign = string_to_sign(http_method, host, path, data) |> generate_signaturev2(secret_key)
  end

  def string_to_sign(http_method, host, path, data) do
    http_method = http_method |> Atom.to_string |> String.upcase

    [http_method, host, path, data] |> Enum.reduce(fn x, acc -> "#{acc}\n#{to_string(x)}" end)
  end

  def encode_hmac_sha256(data, key) do
    :crypto.hmac(:sha256, key, data)
    |> Base.encode64
  end

  def generate_signaturev2(string_to_sign, secret_key) do
    string_to_sign |> encode_hmac_sha256(secret_key)
  end
end
