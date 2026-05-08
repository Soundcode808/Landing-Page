# 노아 지식 창고

이 레포는 베스퍼님의 AI 도구/링크/트렌드 자료를 노아(Claude Code)와 서브 에이전트가 검색·참조하기 위한 외부 창고다.
사람이 보는 용도가 아니다.

---

## 구조

```
README.md       ← 이 파일. 노아용 안내
index.json      ← 전체 항목 메타 인덱스 (검색 진입점)
tags.json       ← 태그 → 항목 ID 역인덱스
items/          ← 항목별 상세 파일 (추후 확장)
```

---

## 검색 방법

### 1단계: 태그로 후보 ID 추출
`tags.json`에서 원하는 태그 키를 찾으면 해당 항목 ID 목록이 나온다.

```
tags.json 예시:
"음악" → ["ace-step-ui", "acestep-cpp", "xai-voice-clone"]
"비용절감" → ["opencode-combo", "ollama-claude"]
```

### 2단계: index.json에서 상세 확인
추출한 ID로 `index.json`에서 해당 항목을 찾는다.
확인할 필드: `summary`, `use_when`, `url`, `status`, `related`

### 필터 기준
- `status: archived` 항목은 폐기됨. 사용하지 말 것.
- `related` 필드로 연관 항목 탐색 가능.
- `use_when` 필드가 현재 작업 맥락과 일치하는지 확인.

---

## raw URL 예시

```
https://raw.githubusercontent.com/Soundcode808/Landing-Page/main/index.json
https://raw.githubusercontent.com/Soundcode808/Landing-Page/main/tags.json
```

---

## 항목 추가 방법

베스퍼님이 노아에게 "이 링크 추가해줘"라고 하면 노아가 처리한다.
추가 시 `index.json`과 `tags.json` 양쪽 모두 업데이트한다.
id는 영문 케밥케이스. `verified_at`은 추가 날짜로 기록.
