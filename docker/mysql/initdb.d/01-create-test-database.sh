#!/bin/bash
# DB を初めて作るとき（ボリュームが空のとき）だけ MySQL の公式イメージが実行するスクリプト。
# 開発用 DB（MYSQL_DATABASE）は自動で作られるので、ここではテスト用 DB を作って同じユーザーに権限を付ける。
set -e

mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`app_test\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON \`app_test\`.* TO '${MYSQL_USER}'@'%';
SQL
