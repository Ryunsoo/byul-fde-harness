---
name: review
description: 내부 개선 루프 — 코드+하네스 산출물 검토 후 개선점 반영, Ralph 재실행 안내
allowed-tools: Read, Write, Grep, Glob, Agent, Bash
---

# /review — 내부 개선 루프 (프로젝트 내 반복 개선)

Ralph Loop 완료 후, 코드와 하네스 산출물을 검토하여 개선점을 식별하고 반영한다.
수정된 하네스로 Ralph Loop을 재실행하여 코드를 리팩토링한다.

## 동작 시점

- Ralph Loop 완료 후 FDE가 `/review` 실행
- 또는 개발 중간에 품질 점검이 필요할 때

## 검토 대상

### 1. 코드 품질
- 빌드/테스트/린트 결과
- 코드 구조와 설계 패턴
- 중복 코드, 불필요한 복잡성
- 요구사항 충족 여부

### 2. 하네스 산출물
- `PROMPT.md` — Phase 분리가 적절한가? 완료 조건이 명확한가? 모호한 지시가 없는가?
- `docs/design.md` — 설계가 과하거나 부족하지 않은가?
- `CLAUDE.md` — 규칙이 실제 코드와 일치하는가?

## 작업 순서

### 1단계: 현황 수집

다음을 병렬로 확인한다:
- `git log --oneline` — 커밋 히스토리
- 빌드 결과 (frontend: `npm run build`, backend: `./gradlew build`)
- 테스트 결과 (frontend: `npm run test`, backend: `./gradlew test`)
- 린트 결과 (frontend: `npm run lint`)
- 현재 파일 구조

### 2단계: 코드 검토

`code-reviewer` 에이전트(`.claude/agents/code-reviewer.md`)를 subagent로 호출하여 코드 품질을 검토한다:
- 작업: 이 프로젝트의 코드를 검토하라. `docs/requirements.md`의 요구사항 충족 여부를 포함하여, 에이전트 정의에 명시된 검토 항목과 심각도 기준에 따라 리뷰하라.
- 출력: `docs/review/code-review.md`에 저장

### 3단계: 하네스 산출물 검토

직접 검토한다:
- `PROMPT.md`를 읽고 실제 개발 과정과 비교
  - Phase가 너무 크거나 작지 않았는가?
  - 완료 조건이 실제로 검증 가능했는가?
  - 모호해서 Ralph가 헤맨 부분이 있었는가?
- `docs/design.md`를 읽고 실제 코드와 비교
  - 설계와 구현이 일치하는가?
  - 과도한 설계 또는 부족한 설계가 있었는가?
- 결과를 `docs/review/harness-review.md`에 저장

### 4단계: 개선 계획 작성

코드 리뷰 + 하네스 리뷰 결과를 종합하여 개선 계획을 작성한다:

`docs/review/improvement-plan.md`:

```markdown
# 개선 계획

## 코드 개선
| 우선순위 | 대상 | 문제 | 개선 방향 |
|---------|------|------|----------|

## 하네스 개선
| 대상 파일 | 문제 | 수정 내용 |
|----------|------|----------|

## 다음 Ralph Loop에서 할 것
(위 개선 사항을 반영한 구체적 작업 목록)
```

### 5단계: 하네스 산출물 수정

개선 계획에 따라 하네스 산출물을 직접 수정한다:
- `PROMPT.md` 수정 (Phase 분리 조정, 완료 조건 구체화, 누락 작업 추가 등)
- `docs/design.md` 수정 (필요 시)
- `CLAUDE.md` 수정 (필요 시)

### 6단계: 교훈 기록

이번 리뷰에서 발견한 교훈을 기록한다:
- `docs/review/lessons.md`에 추가
- 형식: `[날짜] [카테고리] 교훈 내용`
- 카테고리: `prompt`, `design`, `code`, `tooling`

이 교훈은 나중에 `/lesson-learn`(외부 루프)에서 프리셋에 반영할 후보가 된다.

### 7단계: 재실행 안내

수정이 완료되면 아래를 출력한다:

```
## Review 완료

### 수정된 파일
- (수정된 파일 목록)

### 다음 단계
수정된 PROMPT.md로 Ralph Loop을 재실행하세요:

/ralph-loop "PROMPT.md를 참고하여 개발을 진행하라. 기존 코드를 리팩토링하라." --completion-promise "DONE"
```

## 출력

- `docs/review/code-review.md` — 코드 리뷰 결과
- `docs/review/harness-review.md` — 하네스 산출물 리뷰 결과
- `docs/review/improvement-plan.md` — 개선 계획
- `docs/review/lessons.md` — 교훈 기록 (누적)
- 수정된 `PROMPT.md`, `design.md`, `CLAUDE.md` (필요 시)

## 반복 기준

`/review` → `/ralph-loop` → `/review` 사이클은:
- 개선 계획에 "코드 개선" 항목이 남아있으면 계속
- 개선 계획이 비어있거나, 남은 항목이 모두 "다음 프로젝트에서 고려" 수준이면 종료

## 주의사항

- `/review`는 직접 코드를 수정하지 않는다. 하네스 산출물만 수정한다.
- 코드 수정은 항상 Ralph Loop을 통해 이루어진다.
- 검토 결과가 "문제 없음"이면 불필요한 수정을 만들지 않는다.
