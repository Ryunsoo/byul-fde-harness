---
name: lesson-learn
description: 외부 개선 루프 — 프로젝트 완료 후 교훈을 하네스 프리셋에 반영
allowed-tools: Read, Write, Grep, Glob, Agent, Bash
---

# /lesson-learn — 외부 개선 루프 (프리셋 반영)

프로젝트 완료 후, 내부 루프(/review)에서 쌓인 교훈을 하네스 프리셋에 반영한다.
다음 프로젝트가 더 나은 하네스로 시작할 수 있도록 한다.

## 동작 시점

- 프로젝트 완료 후 FDE가 `/lesson-learn` 실행
- 내부 루프(/review)가 종료된 상태에서 실행

## 입력

- `docs/review/lessons.md` — 내부 루프에서 누적된 교훈
- `harness/` — 현재 프리셋

## 작업 순서

### 1단계: 교훈 수집

`docs/review/lessons.md`를 읽고 교훈을 카테고리별로 분류한다:

| 카테고리 | 반영 대상 |
|---------|----------|
| `prompt` | `harness/templates/` (Phase 템플릿) |
| `design` | `/debate` skill 또는 토론 프로토콜 |
| `code` | `harness/conventions/` (컨벤션) |
| `tooling` | `harness/toolsets/` (도구 조합) |

### 2단계: 반영 판단

각 교훈에 대해 판단한다:

- **범용적 교훈** (다른 프로젝트에서도 적용 가능) → 프리셋에 반영
  - 예: "Windows에서 Vitest는 pool: threads 필수" → `toolsets/webapp-frontend.md`에 추가
- **프로젝트 특수적 교훈** (이 프로젝트에만 해당) → 반영하지 않음
  - 예: "별소프트 About 페이지에 강점 섹션 추가" → 스킵
- **판단 보류** (아직 확신 없음) → 메모리에 저장, 다음 프로젝트에서 재발하면 승격

### 3단계: 프리셋 업데이트

범용적 교훈을 해당 프리셋 파일에 반영한다:
- `harness/conventions/` — 컨벤션에 규칙 추가/수정
- `harness/toolsets/` — Known Issues에 추가, 설정 수정
- `harness/templates/` — Phase 구조나 완료 조건 개선
- `.claude/skills/` — skill 프롬프트 개선

### 4단계: 결과 보고

```markdown
# Lesson Learn 결과

## 프리셋에 반영된 교훈
| 교훈 | 반영 파일 | 변경 내용 |
|------|----------|----------|

## 스킵된 교훈 (프로젝트 특수적)
- ...

## 보류된 교훈 (메모리 저장)
- ...

## 변경된 프리셋 파일
- (파일 목록)
```

## 출력

- 수정된 `harness/` 프리셋 파일들
- 보류 교훈 → Claude Code 메모리에 저장
- 결과 보고 (화면 출력)

## 주의사항

- 프리셋은 **범용적**이어야 한다. 특정 프로젝트에만 해당하는 내용을 넣지 않는다.
- 기존 프리셋 내용을 삭제하지 않는다. 추가/수정만 한다.
- 확신이 없는 교훈은 무리하게 반영하지 말고 메모리에 보류한다.
