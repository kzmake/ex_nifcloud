defmodule ExNifcloud do
  @moduledoc File.read!("#{__DIR__}/../README.md")
  use Application

  @doc """
  Perform an Nifcloud request

  ```
  ExNifcloud.Computing.describe_instances |> ExNifcloud.request
  ExNifcloud.Computing.describe_instances |> ExNifcloud.request(region: "jp-east-1")
  ```

  ```
  op = %ExNifcloud.Operation.JSON{
    http_method: :post,
    service: :computing,
    headers: [],
  }
  ExNifcloud.request(op)
  ```
  """
  @spec request(ExNifcloud.Operation.t()) :: term
  @spec request(ExNifcloud.Operation.t(), Keyword.t()) :: {:ok, term} | {:error, term}
  def request(op, config_overrides \\ []) do
    ExNifcloud.Operation.perform(op, ExNifcloud.Config.new(op.service, config_overrides))
  end

  @doc """
  Perform an Nifcloud request, raise if it fails.
  Same as `request/1,2` except it will either return the successful response from Nifcloud or raise an exception.
  """
  @spec request!(ExNifcloud.Operation.t()) :: term | no_return
  @spec request!(ExNifcloud.Operation.t(), Keyword.t()) :: term | no_return
  def request!(op, config_overrides \\ []) do
    case request(op, config_overrides) do
      {:ok, result} ->
        result

      error ->
        raise ExNifcloud.Error, """
        ExNifcloud Request Error!
        #{inspect(error)}
        """
    end
  end
end
