# University-WebSystem hello_app

大学の PBL で継続開発し、最終的にインターネットへ公開することを目標にした Rails アプリケーションです。
授業で配布された [Railsチュートリアル用 Codespaces テンプレート](https://github.com/yasslab/codespaces-railstutorial)（Ruby 3.2 / Rails 7.0）を土台に、サポート中のバージョンへ更新しています。

## 採用バージョン

| 項目 | バージョン | 定義場所 |
| --- | --- | --- |
| Ruby | 3.4.10 | `.ruby-version`（`Gemfile` と Dev Container はこのファイルを参照） |
| Rails | 8.1.3.1 | `Gemfile` / `Gemfile.lock` |
| Bundler | 2.6.9 | `Gemfile.lock` の `BUNDLED WITH` |
| データベース | SQLite 3 | `config/database.yml` |
| フロントエンド | importmap + Turbo + Stimulus + Propshaft | `config/importmap.rb` |
| テスト | Minitest | `test/` |

### 配布版からバージョンアップした理由

- 配布版の Ruby 3.2 と Rails 7.0 はどちらも公式サポートが終了しており、セキュリティ修正が提供されない。公開するアプリの基盤には使えない。
- Ruby 3.4 系と Rails 8.1 系はサポート中で、同じ系列内のセキュリティ修正版を `bundle update rails` で取り込める。
- Ruby 4.0 は gem の互換性と運用実績を優先して現時点では採用しない。
- 併せて、メンテナンスが止まっている `sassc-rails` / `sprockets-rails` / `webdrivers` / `solargraph` を外し、Rails 8.1 標準の Propshaft と Ruby LSP に一本化した。

## 必要なソフトウェア

開発環境は Docker 上の Dev Container に統一しています。**Windows / macOS にインストールした Ruby は使いません。**

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)（Windows / macOS）または Docker Engine（Linux）
- [Visual Studio Code](https://code.visualstudio.com/)
- VS Code 拡張機能 [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Git

GitHub Codespaces でも同じ `.devcontainer/` 設定がそのまま使えます。

## 環境構築（初回）

1. リポジトリをクローンする。

   ```bash
   git clone https://github.com/MogJP/University-WebSystem-hello_app.git
   cd University-WebSystem-hello_app
   ```

2. VS Code でフォルダを開き、右下に表示される **Reopen in Container** を選ぶ。
   表示されない場合はコマンドパレット（`F1`）から **Dev Containers: Reopen in Container** を実行する。
3. コンテナのビルドが終わると `bin/setup --skip-server` が自動で実行され、gem のインストールとデータベースの準備が完了する。

   自動実行に失敗した場合や、あとから依存関係を更新したい場合は、コンテナ内のターミナルで次を実行する。

   ```bash
   bin/setup --skip-server
   ```

コンテナを作り直しても、上記以外の手作業は不要です。

## サーバーの起動

コンテナ内のターミナルで実行します。サーバーは自動起動しません。

```bash
bin/rails server -b 0.0.0.0
```

VS Code がポート 3000 を転送するので、ブラウザで <http://localhost:3000> を開きます。
`/up` はヘルスチェック用のエンドポイントで、アプリが正常に起動していれば 200 を返します。

## テストとセキュリティ検査

すべてコンテナ内で実行します。GitHub Actions でも同じ検査を自動実行します。

```bash
bin/rails test                 # Minitest
bin/rails zeitwerk:check       # 定数の自動読み込みの整合性
bin/rubocop                    # Ruby のスタイル検査（rubocop-rails-omakase）
bin/brakeman --no-pager        # Rails の静的セキュリティ検査
bin/bundler-audit              # 既知の脆弱性を含む gem の検査
bin/importmap audit            # importmap で pin した JavaScript パッケージの脆弱性検査
```

上記をまとめて実行するには次を使います。

```bash
bin/ci
```

## CI

`.github/workflows/ci.yml` が Pull Request と `main` への push で次を実行します。

- Brakeman と bundler-audit によるセキュリティ検査
- importmap の脆弱性検査
- RuboCop
- `bin/rails test`

`.github/dependabot.yml` により、gem と GitHub Actions の更新 PR が毎週自動で作成されます。

## データベースの方針

現時点では SQLite を使い、PostgreSQL は導入していません。

理由:

- 独自モデル、マイグレーション、永続化が必要なデータがまだ存在しない
- PostgreSQL コンテナを足すと、初期構築とトラブルシューティングの対象が増える
- SQLite でも Active Record を使った開発とテストは開始できる

### PostgreSQL への移行条件

次のいずれかに該当した時点で、PostgreSQL 移行のタスクを別途作成します。

- ユーザー登録やログインを実装する
- 授業、履修、申請、投稿など、消失してはいけないデータを保存する
- 複数ユーザーによる同時更新を扱う
- デプロイ先が SQLite ファイル用の永続ボリュームを提供しない
- 本番環境として利用する DB が PostgreSQL に決まる

デプロイ先のファイルシステムが一時的な場合、SQLite の内容は再起動や再デプロイで消える可能性があります。

## 秘密情報の扱い

- `config/credentials.yml.enc` を復号する鍵 `config/master.key` は Git 管理外です。チーム内で安全な手段で共有してください。
- デプロイ時は `RAILS_MASTER_KEY` 環境変数にその内容を設定します。
- 秘密情報や個人情報をリポジトリにコミットしないでください。

## ディレクトリの補足

- `docs/tasks/` — 開発環境刷新などの作業計画
- `app/controllers/hello_controller.rb`, `app/views/hello/` — 配布版から引き継いだ Hello 画面

## ライセンス

配布元テンプレートのライセンスは [LICENSE](LICENSE) を参照してください。
