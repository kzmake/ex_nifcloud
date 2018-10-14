use Mix.Config

config :ex_nifcloud,
  debug_requests: true,
  access_key_id: [{:system, "ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "SECRET_ACCESS_KEY"}, :instance_role],
  region: "jp-east-1"
