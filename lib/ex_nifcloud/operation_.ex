defprotocol ExNifcloud.Operation do
  @doc """
  An operation to perform on Nifcloud
  """
  def perform(operation, config)
end

%ExNifcloud.Operation.Query{
  action: :describe_instances,
  params: %{"Action" => "DescribeInstances"},
  parser: &ExNifcloud.Utils.identity/2,
  path: "/api",
  service: :computing
}