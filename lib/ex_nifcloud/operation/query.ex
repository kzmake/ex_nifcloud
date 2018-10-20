defmodule ExNifcloud.Operation.Query do
  @moduledoc """
  Datastructure representing an operation on a Query based Nifcloud service
  """

  defstruct path: "/api/",
            params: %{},
            service: nil,
            action: nil,
            parser: &ExNifcloud.Utils.identity/2

  @type t :: %__MODULE__{}
end

defimpl ExNifcloud.Operation, for: ExNifcloud.Operation.Query do
  def perform(operation, config) do
    action =
      operation.action
      |> Atom.to_string()
      |> Macro.camelize()

    data =
      operation.params
      |> Map.merge(%{Action: action})

    url =
      operation
      |> Map.delete(:params)
      |> ExNifcloud.Request.Url.build(config)

    headers = [
      {"content-type", "application/x-www-form-urlencoded"}
    ]

    result = ExNifcloud.Request.request(:post, url, data, headers, config, operation.service)
    parser = operation.parser

    cond do
      is_function(parser, 1) ->
        parser.(result)

      is_function(parser, 2) ->
        parser.(result, operation.action)

      is_function(parser, 3) ->
        parser.(result, operation.action, config)

      true ->
        result
    end
  end
end
