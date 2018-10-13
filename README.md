ExNifcloud
================

Description
-----------

パイプライン演算子好きのための Elixir 用 Nifcloud APIs の SDK です。
このリポジトリは、 [ex-aws](https://github.com/ex-aws/ex_aws) を fork して Nifcloud APIs 用に変更されています。


Getting Started
------------

追加したいプロジェクトの　`mix.exs` に `:ex_nifcloud` パッケージを追加し、 `mix deps.get` で依存パッケージをインストールします。

```elixir
def deps do
  [
    {:ex_nifcloud, git: "https://github.com/kzmake/ex_nifcloud.git", branch: "master"},
  ]
end
```

`ExNifcloud.Operation.Query` で生成したオペレーションを `ExNifcloud.request` へパイプさせることで　Nicloud APIs をリクエストします。

```sh
mix run -e '%ExNifcloud.Operation.Query{
              action: :describe_instances,
              params: %{Action: "DescribeInstances"},
              parser: &ExNifcloud.Utils.identity/2,
              path: "/api/",
              service: :computing
             }
            |> ExNifcloud.request(region: "jp-east-1")
            |> IO.inspect'
```

Install
-------

まだ Hex にあげてない。 github から引っ張ってきて。

```elixir
def deps do
  [
    {:ex_nifcloud, git: "https://github.com/kzmake/ex_nifcloud.git", branch: "master"},
  ]
end
```

Preparation
-----------

Nifcloud APIs を利用するに当たり、 `ACCESS_KEY_ID` と `SECRET_ACCESS_KEY` を設定する必要があります。今のところ設定方法は環境変数だけ。

環境変数 で設定する:

```sh
export ACCESS_KEY_ID="your access key"
export SECRET_ACCESS_KEY="your secret access key"
```

TODO:
そのうち、 `config/*.exs` で優先順位をいい感じに設定できるようにする予定。

```elixir
use Mix.Config

config :ex_nifcloud,
       debug_requests: true,
       access_key_id: [{:system, "ACCESS_KEY_ID"}, {:path, "path/to/credential"}],
       secret_access_key: [{:system, "SECRET_ACCESS_KEY"}, {:path, "path/to/credential"}],
       region: "jp-east-1"
```

Usage
-----

`:ex_nifcloud` パッケージインストール済みのプロジェクトにて `iex -S mix` などで実施できます。

`ExNifcloud.Operation.Query` でリクエストしたいクエリを作成し、 `|>` で `ExNifcloud.request(region: "jp-east-1")` へ渡すことでリクエストします。

```elixir
iex> %ExNifcloud.Operation.Query{
      action: :describe_instances,
      params: %{
        Action: "DescribeInstances"
      },
      parser: &ExNifcloud.Utils.identity/2,
      path: "/api/",
      service: :computing
    } |> ExNifcloud.request(region: "jp-east-1") |> IO.inspect

{:ok,
  %{
    body: "...",
    headers: [...],
    status_code: 200
  }
}
```

`ExNifcloud.Operation.Query` の `:parser` をユーザー独自のパーサーに置き換えることで `ExNifcloud.request` の戻り値を自由に変換することも可能です。

```elixir
iex> %ExNifcloud.Operation.Query{
      action: :describe_instances,
      params: %{Action: "DescribeInstances"},
      parser: &StatusCodeParser.parse/1,
      path: "/api/",
      service: :computing
    } |> ExNifcloud.request

200
```

Requirements
------------

このプロジェクトを実行するには以下が必要です:

* [elixir](https://elixir-lang.org) 1.7.+

Contributing
------------

PR歓迎してます


Support and Migration
---------------------

特に無し

License
-------

- [MIT License](http://petitviolet.mit-license.org/)
