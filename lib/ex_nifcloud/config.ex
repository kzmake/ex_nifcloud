defmodule ExNifcloud.Config do
  @moduledoc false

  # Generates the configuration for a service.
  # It starts with the defaults for a given environment
  # and then merges in the common config from the ex_nifcloud config root,
  # and then finally any config specified for the particular service

  @common_config [
    :http_client,
    :json_codec,
    :access_key_id,
    :secret_access_key,
    :debug_requests,
    :region
  ]

  @type t :: %{} | Keyword.t()

  @doc """
  Builds a complete set of config for an operation.
  """
  def new(service, opts \\ []) do
    overrides = Map.new(opts)

    service
    |> build_base(overrides)
    |> retrieve_runtime_config
    |> parse_host_for_region
  end

  def build_base(service, overrides \\ %{}) do
    region = Map.get(overrides, :region) || "jp-east-1"

    defaults = build_defaults(service, region)

    defaults
    |> Map.merge(overrides)
  end

  def build_defaults(service, region) do
    Map.merge(
      %{
        scheme: "https://",
        region: region,
        port: 443
      },
      %{
        access_key_id: [{:system, "ACCESS_KEY_ID"}],
        secret_access_key: [{:system, "SECRET_ACCESS_KEY"}],
        http_client: ExNifcloud.Request.Hackney,
        json_codec: Poison
      }
    )
    |> Map.put(
      :host,
      build_host(
        "{region}.{service}.{dnsSuffix}",
        Atom.to_string(service),
        region,
        "api.nifcloud.com"
      )
    )
  end

  def build_host(hostname, service, region, dns_suffix) do
    hostname
    |> String.replace("{service}", service)
    |> String.replace("{region}", region)
    |> String.replace("{dnsSuffix}", dns_suffix)
  end

  def retrieve_runtime_config(config) do
    Enum.reduce(
      config,
      config,
      fn
        {:host, host}, config ->
          Map.put(config, :host, retrieve_runtime_value(host, config))

        {:http_opts, http_opts}, config ->
          Map.put(config, :http_opts, http_opts)

        {k, v}, config ->
          case retrieve_runtime_value(v, config) do
            %{} = result -> Map.merge(config, result)
            value -> Map.put(config, k, value)
          end
      end
    )
  end

  def retrieve_runtime_value({:system, env_key}, _) do
    System.get_env(env_key)
  end

  def retrieve_runtime_value(values, config) when is_list(values) do
    values
    |> Stream.map(&retrieve_runtime_value(&1, config))
    |> Enum.find(& &1)
  end

  def retrieve_runtime_value(value, _), do: value

  def parse_host_for_region(%{host: {stub, host}, region: region} = config) do
    Map.put(config, :host, String.replace(host, stub, region))
  end

  def parse_host_for_region(%{host: map, region: region} = config) when is_map(map) do
    case Map.fetch(map, region) do
      {:ok, host} -> Map.put(config, :host, host)
      :error -> "A host for region #{region} was not found in host map #{inspect(map)}"
    end
  end

  def parse_host_for_region(config), do: config
end
