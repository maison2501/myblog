#!/bin/bash
# レイアウトで CDN から読み込んでいるファイルについて、integrity（SRI ハッシュ）が実物と一致するか確かめる。
# 一致しないとブラウザがそのファイルを読み込まないので、見た目やエディタが壊れる。
set -uo pipefail

status=0
while IFS= read -r line; do
  url=$(grep -oE 'https://cdn\.jsdelivr\.net/[^"]+' <<< "$line")
  expected=$(grep -oE 'sha384-[^"]+' <<< "$line" || true)
  actual="sha384-$(curl -fsSL "$url" | openssl dgst -sha384 -binary | openssl base64 -A)"
  if [ "$expected" = "$actual" ]; then
    echo "OK   $url"
  else
    echo "NG   $url"
    echo "     expected: ${expected:-（integrity なし）}"
    echo "     actual:   $actual"
    status=1
  fi
done < <(grep -E 'https://cdn\.jsdelivr\.net/' app/views/layouts/application.html.slim)

exit $status
