# AI 브리핑 아카이브

부산 PC 심부름꾼이 매일 07:30에 수집한 AI 동향 raw 데이터.

## 파일 구조
- `YYYY-MM-DD-raw.md` — 부산 PC cron이 자동 커밋 (arXiv RSS + HF API 원시 결과)
- `YYYY-MM-DD.md` — 노아가 L1 요약 정제 후 커밋 (Telegram 발송본)

## 수집 도메인
1. AI 음악 — arXiv cs.SD, HF text-to-audio
2. AI 이미지 — arXiv cs.CV, HF text-to-image
3. AI 영상 — HF text-to-video / image-to-video
4. 메타버스·3D — Unreal/Unity/Godot RSS, HF text-to-3d
5. LLM 종합 — arXiv cs.AI+cs.CL, OpenAI/Anthropic 공식 RSS
6. HF 신규 모델 — 전 도메인 createdAt 기준 어제 없던 것
