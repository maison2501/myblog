# Blog Maison

Markdown で書ける個人ブログ（Ruby on Rails）。

- Ruby 3.4 / Rails 8.1 / MySQL 8.0
- 画面：Slim テンプレート ＋ Start Bootstrap「Clean Blog」テーマ
- JavaScript：importmap ＋ Turbo ＋ Stimulus（Node.js 不要）
- 記事の編集画面：EasyMDE（Markdown エディタ、画像の貼り付け対応）
- 記事の表示：Redcarpet（Markdown）＋ Rouge（コードの色付け）

## 起動のしかた（Docker）

```sh
# 1. 管理者パスワードを決めて .env に書く（.env は Git に入らない）
echo "ADMIN_PASSWORD=好きなパスワード" > .env

# 2. ビルドと DB の準備
docker compose build
docker compose run --rm app bin/rails db:prepare

# 3. 起動
docker compose up
```

http://localhost:3000 を開く。

## 記事を書く（管理者ログイン）

http://localhost:3000/login を開き、`.env` に書いたパスワードでログインする。
ログイン中だけ、メニューに「New Post」「Logout」、記事ページに「編集する」「削除する」が出る。

- パスワードは環境変数 `ADMIN_PASSWORD`、または `bin/rails credentials:edit` で `admin_password: ...` として設定する
- どちらも未設定なら、誰もログインできない（閲覧だけのブログになる）
- ログインの試行は 3 分間に 10 回まで

## テスト

```sh
docker compose run --rm app bundle exec rspec
```

GitHub に push すると、GitHub Actions でも自動でテストが走る（`.github/workflows/ci.yml`）。

## gem の更新

Dependabot が毎週チェックして、更新のプルリクエストを作る（`.github/dependabot.yml`）。
手元でまとめて上げるときは：

```sh
docker compose run --rm app bundle update
docker compose run --rm app bundle exec rspec
```

## 本番で動かすとき

- `SECRET_KEY_BASE`（または `config/master.key`）と `ADMIN_PASSWORD` を設定する
- HTTPS で公開するなら `config/environments/production.rb` の `config.assume_ssl` / `config.force_ssl` を有効にする
- 死活監視には `/up` を使える
