#!/usr/bin/env bash
# 부산 심부름꾼 — AI 브리핑 수집기
# cron: 30 7 * * * /opt/briefing/collect.sh >> /opt/briefing/collect.log 2>&1
# 환경변수 필요: TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID, GITHUB_TOKEN

set -euo pipefail

REPO_DIR="/opt/briefing/Landing-Page"
TODAY=$(date +%Y-%m-%d)
OUT="${REPO_DIR}/briefings/${TODAY}-raw.md"
LOG_PREFIX="[$(date '+%Y-%m-%d %H:%M:%S')]"

echo "$LOG_PREFIX 수집 시작"

# 레포 최신화
cd "$REPO_DIR"
git pull --quiet

# 이미 오늘 raw 파일 있으면 건너뜀 (중복 방지)
if [[ -f "$OUT" ]]; then
  echo "$LOG_PREFIX 오늘 파일 이미 있음, 종료"
  exit 0
fi

cat > "$OUT" <<HEADER
# AI 브리핑 Raw — ${TODAY}
> 수집: 부산 심부름꾼 $(date '+%H:%M KST') | 정제: 노아(Mac) 대화 중 요청 시

HEADER

# ── arXiv RSS ────────────────────────────────────────────
fetch_arxiv() {
  local feed="$1" label="$2"
  local xml
  xml=$(curl -sfL --max-time 30 "$feed") || { echo "⚠️ arXiv $label fetch 실패"; return; }
  echo "## arXiv — ${label}"
  echo "$xml" \
    | grep -oP '(?<=<title>)[^<]+' \
    | grep -v '^cs\.' \
    | head -10 \
    | sed 's/^/- /'
  echo ""
}

fetch_arxiv "https://rss.arxiv.org/rss/cs.SD"          "AI 음악 (cs.SD)"
fetch_arxiv "https://rss.arxiv.org/rss/cs.CV"          "AI 이미지 (cs.CV)"
fetch_arxiv "https://rss.arxiv.org/rss/cs.AI+cs.CL"   "LLM 종합 (cs.AI+cs.CL)"

# ── HuggingFace API ───────────────────────────────────────
fetch_hf() {
  local filter="$1" label="$2"
  local url="https://huggingface.co/api/models?filter=${filter}&sort=createdAt&direction=-1&limit=8"
  local json
  json=$(curl -sfL --max-time 30 "$url") || { echo "⚠️ HF $label fetch 실패"; return; }
  echo "## HuggingFace 신규 — ${label}"
  echo "$json" \
    | grep -oP '"id"\s*:\s*"\K[^"]+' \
    | head -8 \
    | sed 's/^/- /'
  echo ""
}

fetch_hf "text-to-audio"    "AI 음악"
fetch_hf "text-to-image"    "AI 이미지"
fetch_hf "text-to-video"    "AI 영상"
fetch_hf "text-to-3d"       "AI 3D"

# ── HF 트렌딩 (좋아요·다운로드 급증) ─────────────────────
echo "## HuggingFace 트렌딩 (전 도메인)"
curl -sfL --max-time 30 \
  "https://huggingface.co/api/models?sort=trending&limit=10" \
  | grep -oP '"id"\s*:\s*"\K[^"]+' \
  | head -10 \
  | sed 's/^/- /' \
  || echo "⚠️ HF 트렌딩 fetch 실패"
echo ""

# ── 공식 블로그 RSS ───────────────────────────────────────
fetch_blog() {
  local url="$1" label="$2"
  local xml
  xml=$(curl -sfL --max-time 20 "$url") || { echo "⚠️ $label fetch 실패"; return; }
  echo "## 공식 블로그 — ${label}"
  echo "$xml" \
    | grep -oP '(?<=<title>)[^<]+' \
    | grep -v '^$' \
    | head -3 \
    | sed 's/^/- /'
  echo ""
}

fetch_blog "https://www.unrealengine.com/en-US/feed" "Unreal Engine"
fetch_blog "https://blog.unity.com/feed"             "Unity"

# ── GitHub 커밋 ──────────────────────────────────────────
cd "$REPO_DIR"
git config user.email "dsddltngh1@gmail.com"
git config user.name  "Soundcode808"
git add "briefings/${TODAY}-raw.md"
git commit -m "chore(briefing): ${TODAY} raw 수집 — 부산 심부름꾼"

# GITHUB_TOKEN 환경변수로 push (토큰 노출 없이)
git push "https://Soundcode808:${GITHUB_TOKEN}@github.com/Soundcode808/Landing-Page.git" main

echo "$LOG_PREFIX 수집 완료 — ${OUT}"

# ── Telegram 알림 (토큰 있을 때만) ───────────────────────
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]]; then
  LINE_COUNT=$(grep -c '^- ' "$OUT" || true)
  curl -s -X POST \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=🌅 ${TODAY} 브리핑 raw 수집 완료 (항목 ${LINE_COUNT}개). 노아한테 '오늘 브리핑 요약해줘' 하면 됩니다." \
    --silent --output /dev/null
fi
