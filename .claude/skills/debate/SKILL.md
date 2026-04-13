---
name: debate
description: 멀티에이전트 설계 토론 (How) — Agent A/B가 경쟁하여 최적 설계안 도출
allowed-tools: Read, Write, Grep, Glob, Agent, Bash
---

# /debate — 멀티에이전트 설계 토론 (How)

분석 결과를 바탕으로 멀티에이전트 토론을 통해 "어떻게 만들 것인가"의 최적 설계안을 도출하라.

## 에이전트 정의

- `.claude/agents/architect-radical.md` — Agent A (급진적 페르소나)
- `.claude/agents/architect-stable.md` — Agent B (논리적 페르소나)
- `.claude/agents/moderator.md` — 사회자

## 입력

- `docs/analysis.md` — `/analyze`의 출력물 (필수)

## 토론 범위

기술 설계 전체:
- API 엔드포인트 설계
- 데이터 모델 (Entity, 필드, 관계)
- 화면 구조 + 라우팅
- 공통 컴포넌트 구성
- 기술적 결정 사항 (상태 관리, 통신 방식 등)

## 토론 프로토콜

### 1단계: 설계안 작성

`architect-radical` 에이전트와 `architect-stable` 에이전트를 **병렬로** subagent 호출한다.

**Agent A** (`architect-radical`):
- 작업: `docs/analysis.md`를 읽고 기술 설계안을 작성하라.
- 출력: `docs/debate/agent-a.md`에 저장

**Agent B** (`architect-stable`):
- 작업: `docs/analysis.md`를 읽고 기술 설계안을 작성하라.
- 출력: `docs/debate/agent-b.md`에 저장

### 2단계: 교차 검증 + 반론

두 에이전트를 **병렬로** 다시 호출한다.

**Agent A** (`architect-radical`):
- 작업: `docs/debate/agent-b.md`를 읽고 약점, 비효율, 개선점을 지적하라.
- 출력: `docs/debate/review-a.md`에 저장

**Agent B** (`architect-stable`):
- 작업: `docs/debate/agent-a.md`를 읽고 약점, 위험, 과도한 복잡성을 지적하라.
- 출력: `docs/debate/review-b.md`에 저장

### 3단계: 수정

두 에이전트를 **병렬로** 다시 호출한다.

**Agent A** (`architect-radical`):
- 작업: `docs/debate/review-b.md`의 비판을 검토하고 타당한 지적을 반영하여 설계안을 수정하라.
- 출력: `docs/debate/agent-a-final.md`에 저장

**Agent B** (`architect-stable`):
- 작업: `docs/debate/review-a.md`의 비판을 검토하고 타당한 지적을 반영하여 설계안을 수정하라.
- 출력: `docs/debate/agent-b-final.md`에 저장

### 4단계: 사회자 판정

`moderator` 에이전트(`.claude/agents/moderator.md`)를 subagent로 호출한다:
- 작업: `docs/debate/agent-a-final.md`와 `docs/debate/agent-b-final.md`를 읽고, 각 안을 평가하라. A/B의 장점을 조합한 제3안을 생성한 뒤, 3개 안 중 최적안을 선정하라. 최적안을 기반으로 `docs/design.md`를 작성하라.
- 출력: `docs/design.md` (최적안 + 선정 근거 + 토론 기록 포함)

## 출력

**메인 출력: `docs/design.md`**

```markdown
# 설계 결과

## 선정된 설계안
(최적안 요약 + 선정 근거)

## API 설계
| Method | Endpoint | 설명 |
|--------|----------|------|

## 데이터 모델
(Entity, 필드, 관계)

## 화면 구조
| 화면 | 경로 | 주요 기능 |
|------|------|----------|

## 공통 컴포넌트
(헤더, 푸터, 레이아웃 등)

## 기술적 결정 사항
(상태 관리, API 통신 방식 등)

## 토론 기록
### Agent A안 요약
### Agent B안 요약
### 사회자 평가
```

**토론 중간 산출물: `docs/debate/`** (참고용으로 보존)

## 주의사항

- Agent A와 B는 반드시 **서로 다른 접근**을 해야 한다. 비슷한 설계안이 나오면 토론의 의미가 없다.
- 토론 단계에서 병렬 호출이 가능한 단계는 반드시 병렬로 실행하라.
- 사회자는 단순히 "좋은 것만 고르기"가 아니라, 두 안의 장점을 조합한 제3안을 반드시 생성하라.

## 산출물 커밋

출력 완료 후, 설계 결과와 토론 산출물을 git commit 한다:
```
git add docs/design.md docs/debate/
git commit -m "docs: add design result from multi-agent debate"
```

## 완료 조건

- `docs/design.md` 파일이 생성됨
- 위 형식의 모든 섹션이 포함됨
- `docs/debate/` 디렉토리에 토론 중간 산출물이 보존됨
- 선정 근거가 명확히 기술됨
- git commit 완료
