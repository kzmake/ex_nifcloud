defprotocol ExNifcloud.Operation do
  @doc """
  An operation to perform on Nifcloud
  """
  def perform(operation, config)
end
