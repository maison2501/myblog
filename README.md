# Blog Maison

Markdown で書ける個人ブログ（Ruby on Rails）。

- Ruby 3.4 / Rails 8.1 / MySQL 8.4
- 画面：Slim テンプレート ＋ Bootstrap 5.3（CDN）＋ Start Bootstrap「Clean Blog」テーマ（差分だけ `theme.css` に）
- JavaScript：importmap ＋ Turbo ＋ Stimulus（Node.js 不要）
- 記事の編集画面：EasyMDE（Markdown エディタ、画像の貼り付け対応）
- 記事の表示：Redcarpet（Markdown）＋ Rouge（コードの色付け）

## 起動のしかた（Docker）

```sh
# 1. 管理者パスワードを決めて .env に書く（.env は Git に入らない）
echo "ADMIN_PASSWORD=好きなパスワード" > .env

# 2. 起動（初回はイメージのビルドと DB の初期化で数分かかる）
docker compose up -d

# 3. DB の準備（初回と、マイグレーションを追加したとき）
docker compose exec app bin/rails db:prepare
```

http://localhost:3000 を開く。止めるときは `docker compose down`。

### Docker の構成

| ファイル | 役割 |
|---|---|
| `compose.yaml` | 開発用。MySQL（公式イメージ）とアプリの2つのコンテナ |
| `docker/dev/Dockerfile` | 開発用のアプリのイメージ。ソースはマウントするので gem だけ入れる |
| `docker/mysql/` | MySQL の設定と、初回だけ実行されるテスト用 DB の作成スクリプト |
| `Dockerfile` | 本番用のイメージ（マルチステージビルド、root 以外のユーザーで実行） |
| `.dockerignore` | イメージに入れないファイル（秘密情報やログなど） |

- DB のデータは `db-data` ボリュームに残る。`docker compose down -v` で消える
- Gemfile を変えたら `docker compose build` し直す
- DB に直接つなぐなら `docker compose exec app bin/rails dbconsole`
- `binding.irb` で止めたときは `docker compose attach app` で操作できる（抜けるのは Ctrl+P → Ctrl+Q）

## 記事を書く（管理者ログイン）

http://localhost:3000/login を開き、`.env` に書いたパスワードでログインする。
ログイン中だけ、メニューに「New Post」「Logout」、記事ページに「編集する」「削除する」が出る。

- パスワードは環境変数 `ADMIN_PASSWORD`、または `bin/rails credentials:edit` で `admin_password: ...` として設定する
- どちらも未設定なら、誰もログインできない（閲覧だけのブログになる）
- ログインの試行は 3 分間に 10 回まで

## テスト

```sh
docker compose exec -e RAILS_ENV=test app bin/rails db:prepare   # 初回だけ
docker compose exec app bundle exec rspec
```

コードの書き方のチェック（RuboCop、Rails 公式ルール）：

```sh
docker compose exec app bin/rubocop      # チェック
docker compose exec app bin/rubocop -a   # 直せるものは自動で直す
```

GitHub では次の3つが自動で走る（`.github/workflows/`）。

- `ci.yml`：テスト、マイグレーションと `db/schema.rb` の一致、RuboCop、CDN ファイルの integrity
- `docker.yml`：開発用 compose の起動とその中でのテスト、本番用イメージのビルドと起動確認
- `screenshots.yml`：プルリクエストのとき、実際にブラウザで操作して各画面を撮影

## gem の更新

Dependabot が毎週チェックして、更新のプルリクエストを作る（`.github/dependabot.yml`）。
手元でまとめて上げるときは：

```sh
docker compose run --rm app bundle update
docker compose build
docker compose exec app bundle exec rspec
```

## 本番で動かすとき

```sh
docker build -t myblog .
docker run -p 3000:3000 \
  -e SECRET_KEY_BASE=$(openssl rand -hex 64) \
  -e DATABASE_HOST=<MySQL のホスト> -e APP_DATABASE_PASSWORD=<DB パスワード> \
  -e ADMIN_PASSWORD=<管理者パスワード> \
  -v myblog-storage:/rails/storage \
  myblog
```

- 起動時に DB の作成とマイグレーションが自動で走る（`bin/docker-entrypoint`）
- アップロード画像は `/rails/storage` に保存されるので、ボリュームをつないで残す
- HTTPS で公開するなら `config/environments/production.rb` の `config.assume_ssl` / `config.force_ssl` を有効にする
- 死活監視には `/up` を使える
