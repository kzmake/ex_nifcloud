use Mix.Config

config :ex_nifcloud,
  debug_requests: true,
  access_key_id: [{:system, "ACCESS_KEY_ID"}],
  secret_access_key: [{:system, "SECRET_ACCESS_KEY"}],
  region: "jp-east-1"
