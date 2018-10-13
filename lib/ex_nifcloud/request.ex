defmodule ExNifcloud.Request do
  require Logger

  @moduledoc """
  Makes requests to Nifcloud.
  """

  @type http_status :: pos_integer
  @type success_content :: %{body: binary, headers: [{binary, binary}]}
  @type success_t :: {:ok, success_content}
  @type error_t :: {:error, {:http_error, http_status, binary}}
  @type response_t :: success_t | error_t
  def request(http_method, url, data, headers, config, service) do
    body =
      case data do
        [] -> %{}
        d when is_binary(d) -> d
        _ -> data
      end

    request_and_retry(http_method, url, service, config, headers, body, {:attempt, 1})
  end

  def request_and_retry(_method, _url, _service, _config, _headers, _req_body, {:error, reason}),
      do: {:error, reason}

  def request_and_retry(method, url, service, config, headers, req_body, {:attempt, attempt}) do
    body = ExNifcloud.Auth.body(method, url, req_body, config)

    with {:ok, body} <- body do
      safe_url = replace_spaces(url)

      body = body |> URI.encode_query

      if config[:debug_requests] do
        Logger.debug("Request Method: #{inspect(method)}}")
        Logger.debug("Request HEADERS: #{inspect(headers)}")
        Logger.debug("Request URL: #{inspect(safe_url)}")
        Logger.debug("Request BODY: #{inspect(body)}")
      end

      case config[:http_client].request(
             method,
             safe_url,
             body,
             headers,
             Map.get(config, :http_opts, [])
           ) do
        {:ok, %{status_code: status} = resp} when status in 200..299 or status == 304 ->
          {:ok, resp}

        {:ok, %{status_code: status} = _resp} when status == 301 ->
          Logger.warn("ExNifcloud: Received redirect, did you specify the correct region?")
          {:error, {:http_error, status, "redirected"}}

        {:ok, %{status_code: status} = resp} when status in 400..499 ->
          {:error, resp}

        {:ok, %{status_code: status} = resp} when status >= 500 ->
          {:error, resp}


        {:error, %{reason: reason}} ->
          Logger.warn("ExNifcloud: HTTP ERROR: #{inspect(reason)}")
      end
    end
  end

  def client_error(%{status_code: status, body: body} = error, json_codec) do
    case json_codec.decode(body) do
      {:ok, %{"__type" => error_type, "message" => message} = err} ->
        error_type
        |> String.split("#")
        |> case do
             [_, type] -> handle_nifcloud_error(type, message)
             _ -> {:error, {:http_error, status, err}}
           end

      _ ->
        {:error, {:http_error, status, error}}
    end
  end

  def client_error(%{status_code: status} = error, _) do
    {:error, {:http_error, status, error}}
  end

  def handle_nifcloud_error("ProvisionedThroughputExceededException" = type, message) do
    {:retry, {type, message}}
  end

  def handle_nifcloud_error("ThrottlingException" = type, message) do
    {:retry, {type, message}}
  end

  def handle_nifcloud_error(type, message) do
    {:error, {type, message}}
  end

  defp replace_spaces(url) do
    String.replace(url, " ", "%20")
  end
end
