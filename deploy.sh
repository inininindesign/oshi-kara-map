#!/bin/bash
cd "$(dirname "$0")"

# デプロイ時刻をHTMLに埋め込む
TIMESTAMP=$(date +%s)
sed -i '' "s/<!-- deploy:[0-9]* -->/<!-- deploy:$TIMESTAMP -->/" index.html 2>/dev/null
# 初回は行がないので追記
if ! grep -q "<!-- deploy:" index.html; then
  sed -i '' "s|</head>|<!-- deploy:$TIMESTAMP --></head>|" index.html
fi

git add index.html deploy.sh
git commit -m "update"
git push

echo "⏳ デプロイ待機中..."

URL="https://inininindesign.github.io/oshi-kara-map/"
for i in $(seq 1 40); do
  sleep 5
  LIVE=$(curl -s "$URL" | grep -o "deploy:[0-9]*" | head -1)
  if [ "$LIVE" = "deploy:$TIMESTAMP" ]; then
    echo "✅ サイトに反映されました！ $URL"
    afplay /System/Library/Sounds/Glass.aiff
    exit 0
  fi
  echo "  確認中... ($((i*5))秒経過)"
done

echo "⚠️ タイムアウト。サイトを直接確認: $URL"
