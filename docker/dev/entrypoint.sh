#!/bin/bash
set -e

# 前回コンテナを止めたときに残った PID ファイルを消す（残っていると「サーバー起動済み」とみなされて起動できない）
rm -f /app/tmp/pids/server.pid

# CMD（または compose.yaml の command）を実行する
exec "$@"
