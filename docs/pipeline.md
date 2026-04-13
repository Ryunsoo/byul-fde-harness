# FDE 하네스 파이프라인

이 문서는 FDE 하네스의 전체 실행 순서와 각 단계에서 지켜야 할 규칙을 정의한다.
Claude는 프로젝트 작업 시작 시 이 문서를 먼저 읽고 파이프라인을 따라 진행한다.

## 전체 파이프라인

```
docs/requirements.md (FDE 작성)
         ↓
    /analyze          → docs/analysis.md
         ↓
    /debate           → docs/design.md, docs/debate/
         ↓
    /generate         → CLAUDE.md, PROMPT.md
         ↓
    /ralph-loop       → 실제 코드 개발
         ↓
    /review           → 코드/하네스 검토 → 필요 시 Ralph 재실행
         ↓
    /lesson-learn     → 교훈을 하네스 프리셋에 반영 (프로젝트 완료 후)
```

## 각 단계의 역할

| 단계 | 역할 | 입력 | 출력 |
|------|------|------|------|
| `/analyze` | What — 뭘 만들어야 하나 | `docs/requirements.md` | `docs/analysis.md` |
| `/debate` | How — 어떻게 만들 것인가 | `docs/analysis.md` | `docs/design.md`, `docs/debate/` |
| `/generate` | Execute — 실행 지시서 조립+생성 | `docs/analysis.md`, `docs/design.md`, `harness/` | `CLAUDE.md`, `PROMPT.md` |
| `/ralph-loop` | 자동 반복 개발 | `PROMPT.md` | 구현된 코드 |
| `/review` | 내부 개선 루프 | 코드, 하네스 산출물 | 수정된 하네스 산출물, 교훈 |
| `/lesson-learn` | 외부 개선 루프 | `docs/review/lessons.md` | 업데이트된 프리셋 |

## 규칙

### 단계 순서
- 반드시 위 순서대로 실행한다. 앞 단계를 건너뛰지 않는다.
- 각 단계는 이전 단계의 산출물을 입력으로 사용한다.

### 산출물 커밋
- `/analyze`, `/debate`, `/generate`는 각 단계 완료 시 산출물을 git commit 한다.
- Ralph Loop은 각 Phase 완료 시 커밋한다 (PROMPT.md에 명시됨).

### 에이전트 호출
- `/debate`는 `.claude/agents/architect-radical`, `architect-stable`, `moderator` 에이전트를 사용한다.
- `/review`는 `.claude/agents/code-reviewer` 에이전트를 사용한다.
- subagent 호출 시 병렬 실행이 가능한 단계는 반드시 병렬로 실행한다.

### 프리셋 사용
- `/generate`는 `harness/conventions/`, `harness/toolsets/`, `harness/templates/`의 프리셋을 조립하여 `CLAUDE.md`를 만든다.
- 해당 기술 스택의 프리셋이 없으면 `analysis.md` 기반으로 직접 작성한다.

### 개선 루프
- `/ralph-loop` 완료 후 `/review`를 실행한다.
- `/review` 결과로 하네스 산출물(PROMPT.md 등)이 수정되면, Ralph Loop을 다시 실행하여 코드를 리팩토링한다.
- `/review`의 개선 계획이 비어있을 때까지 이 사이클을 반복한다.
- 프로젝트 완료 시 `/lesson-learn`으로 교훈을 프리셋에 반영한다.

## 모델 권장 설정

비용 효율을 위해 역할별로 다른 모델을 사용한다.

### 오케스트레이터 (메인 세션)
- **Sonnet 4.6** 권장
- 역할: skill 파일 읽기, subagent 호출, 결과 수집, 단계 전환
- 깊은 추론은 모든 subagent에 위임되어 있어 Sonnet으로 충분

### 에이전트 (subagent)
각 에이전트의 `model` frontmatter에 정의되어 있다.

| 에이전트 | 모델 | 이유 |
|---------|------|------|
| architect-radical | Opus | 혁신적 설계안 도출 시 깊은 추론 필요 |
| architect-stable | Sonnet | 검증된 패턴 기반 설계는 Sonnet으로 충분 |
| moderator | Opus | 3개 안 평가와 종합은 품질이 전체 결과를 좌우 |
| code-reviewer | Sonnet | 코드 리뷰는 패턴 매칭 위주 |

## Hooks (자동 강제 장치)

### Claude Code Stop Hook
- 파일: `.claude/hooks/check-artifact-commit.sh`
- 설정: `.claude/settings.json`
- 동작: Claude가 응답을 마치려 할 때, 아래 산출물이 커밋되지 않았으면 차단하고 커밋 지시:
  - `docs/analysis.md`
  - `docs/design.md`
  - `CLAUDE.md`
  - `PROMPT.md`
- 목적: skill이 산출물 커밋 단계를 빠뜨려도 hook이 강제 실행시킨다

### Git Pre-commit Hook
- 파일: `.husky/pre-commit`
- 동작:
  1. lint-staged로 staged 파일의 prettier + eslint 실행
  2. TS 파일이 staged 되어 있으면 타입체크(`tsc --noEmit`) 실행
- 목적: 커밋 시 포맷/린트/타입 오류를 사전 차단

## 참고 문서

- `process-harness-plan.md` — 하네스 전체 설계 문서
- `harness/templates/requirements-template.md` — 요구사항서 템플릿
- `.claude/skills/*/SKILL.md` — 각 skill의 상세 동작
- `.claude/agents/*.md` — 각 에이전트의 역할과 페르소나
- `.claude/hooks/*.sh` — Claude Code hook 스크립트
- `.claude/settings.json` — Claude Code hook 설정
