# FDE 프로세스 하네스 설계

## 1. 개요

### 하네스란
FDE(Forward Deployed Engineer)가 프로젝트를 진행하는 **전체 과정을 통일화**하는 환경.
코드 품질 도구(린트, 테스트 등)뿐만 아니라, 요구사항 분석부터 개발 완료까지의 **프로세스 자체**를
정해진 틀로 제공한다.

### 하네스의 두 계층

| 계층 | 이름 | 역할 | 상태 |
|------|------|------|------|
| 1층 | 개발 도구 하네스 | 코드 품질을 자동 보장하는 도구 체인 (ESLint, Prettier, Vitest, Checkstyle 등) | 구축 완료 |
| 2층 | 프로세스 하네스 | 프로젝트 진행 과정을 통일화하는 프롬프트 환경 (skills, hooks, subagents) | **설계 중** |

### 현재 목표
웹앱 프로젝트에 특화된 프로세스 하네스를 먼저 완성한다.

### 최종 목표
웹앱에서 검증된 틀을 기반으로 범용 프로세스 하네스로 확장한다 (API, CLI 등).

### 참고 사례
- Pluuug 팀의 하네스 엔지니어링 (B2B SaaS 개발)
  - 출처: https://lilys.ai/digest/9019918/10298417

---

## 2. 핵심 원칙

- **교체 가능한 것**: 기술 스택, 요구사항
- **고정되는 것**: 진행 방식(프로세스)
- **FDE의 역할**: 요구사항서 작성 → 나머지는 하네스가 처리
- **완전 자동**: 요구사항서 입력 후 FDE 개입 없이 개발 완료까지 진행
- **프리셋 기반**: 컨벤션, 하네스 도구, Phase 템플릿은 미리 정의해두고 조립하여 사용

---

## 3. 파이프라인

```
[FDE가 requirements.md 작성]
         │
         ▼
   ┌─────────────┐
   │  /analyze    │  ← skill: 요구사항 분석 (What)
   │  (subagent)  │    - 요구사항서 읽기
   │              │    - 기술 스택 확정 (FDE 지정 + AI 보완)
   │              │    - 구현 범위 정리
   └──────┬──────┘
          │ docs/analysis.md
          ▼
   ┌─────────────────┐
   │  /debate         │  ← skill: 멀티에이전트 토론 (How)
   │  (multi-agent)   │    - Agent A vs Agent B (서로 다른 모델/페르소나)
   │                  │    - 기술 설계 전체를 놓고 경쟁
   │                  │    - 사회자가 판정 + 최적안 자동 선정
   └──────┬──────────┘
          │ docs/design.md
          ▼
   ┌──────────────────┐
   │  /generate        │  ← skill: 산출물 조립+생성 (Execute)
   │  (subagent)       │    - CLAUDE.md: 프리셋에서 조립
   │                   │    - PROMPT.md: 설계안 기반 생성
   └──────┬───────────┘
          │ CLAUDE.md + PROMPT.md
          ▼
   ┌─────────────┐
   │  /ralph-loop │  ← 기존 Ralph Loop
   │  (hooks)     │    - PROMPT.md 기반 자동 개발
   │              │    - 각 Phase 자동 진행
   │              │    - Phase별 검증 (빌드, 테스트, 린트)
   └──────┬──────┘
          │
          ▼
   ┌─────────────────┐
   │  자기 개선 루프   │  ← 자동 동작
   │  (lesson-learn)  │    - 스프린트 완료 후 피드백 수집
   │                  │    - 좋은 패턴 → 가이드로 승격
   │                  │    - 나쁜 패턴 → 메모리 저장 → 재발 방지
   │                  │    - 스프린트 반복 시 하네스 자체가 발전
   └─────────────────┘
```

---

## 4. Skill 상세 설계

### 4.1 `/analyze` — What (뭘 만들어야 하나)

**역할:** 요구사항서를 읽고, 개발에 필요한 핵심 정보만 추출/정리

**입력:**
- `docs/requirements.md` (FDE 작성)
- (선택) FDE가 사전 지정한 기술 스택

**동작:**
1. 요구사항서 읽기
2. 기술 스택 확정 (FDE 지정 항목 존중, 미지정 항목은 AI 보완)
3. 구현 범위 정리 (포함/제외)
4. 핵심 요구사항 추출

**출력: `docs/analysis.md`**

```markdown
# 프로젝트 분석 결과

## 1. 프로젝트 개요
(요구사항서 핵심 한줄 요약)

## 2. 기술 스택
(FDE 지정 항목 + AI 보완)

## 3. 구현 범위
- 포함: (화면/기능 목록)
- 제외: (명시적 제외 항목)

## 4. 핵심 요구사항 요약
(요구사항서에서 개발에 직접 필요한 핵심만 추출)
```

---

### 4.2 `/debate` — How (어떻게 만들 것인가)

**역할:** 분석 결과를 입력으로, 멀티에이전트 토론을 통해 최적 설계안 도출

**입력:** `docs/analysis.md`

**토론 범위:** 기술 설계 전체
- API 엔드포인트 설계
- 데이터 모델 (Entity/필드)
- 화면 구조 + 라우팅
- 공통 컴포넌트 구성
- 기술적 결정 사항 (상태 관리, 통신 방식 등)

**토론 프로토콜:**

```
1단계: Agent A, B 각자 설계안 작성
   ├─ Agent A (급진적): 혁신적/도전적 설계안
   └─ Agent B (논리적): 안정적/검증된 설계안

2단계: 교차 검증 + 반론
   ├─ Agent A가 B의 설계안 비판
   └─ Agent B가 A의 설계안 비판

3단계: 수정
   ├─ Agent A가 반론을 반영하여 설계안 수정
   └─ Agent B가 반론을 반영하여 설계안 수정

4단계: 사회자 판정
   ├─ A안, B안 평가
   ├─ 제3안 생성 (A/B 장점 조합 또는 새로운 접근)
   └─ 최적안 선정 + 선정 근거
```

```
┌──────────┐     ┌──────────┐
│ Agent A   │     │ Agent B   │
│ (급진적)  │     │ (논리적)  │
│           │     │           │
│ 1. 설계안 │     │ 1. 설계안 │
│ 2. 반론   │←───→│ 2. 반론   │
│ 3. 수정   │     │ 3. 수정   │
└─────┬────┘     └─────┬────┘
      │                │
      ▼                ▼
   ┌──────────────────────┐
   │     사회자 Agent       │
   │  - A/B 평가           │
   │  - 제3안 생성          │
   │  - 최적안 선정         │
   └──────────┬───────────┘
              │
              ▼
        [3개 설계안 + 최적안 판정]
```

**왜 멀티에이전트 토론인가?**
- 단일 모델에게 "시안 3개 만들어줘"하면 1번만 잘 만들고 2, 3번은 성의 없음
- 서로 다른 모델/페르소나가 경쟁하면 진짜 다른 결과물이 나옴
- 교차 검증과 반론으로 각 안의 약점이 사전에 보완됨

**최적안 선택:** 사회자 AI가 자동 선정

**출력: `docs/design.md`**

```markdown
# 설계 결과

## 선정된 설계안
(사회자가 선정한 최적안 + 선정 근거)

## API 설계
| Method | Endpoint | 설명 |

## 데이터 모델
(Entity, 필드, 관계)

## 화면 구조
| 화면 | 경로 | 주요 기능 |

## 공통 컴포넌트
(헤더, 푸터, 레이아웃 등)

## 기술적 결정 사항
(상태 관리, API 통신 방식 등)

## 토론 기록 (참고용)
### Agent A안 요약
### Agent B안 요약
### 사회자 평가
```

---

### 4.3 `/generate` — Execute (실행 지시서 만들기)

**역할:** 확정된 설계를 실행 가능한 산출물(CLAUDE.md + PROMPT.md)로 변환

**핵심 개념: 프리셋 기반 조립**

CLAUDE.md에 들어가는 컨벤션, 하네스 도구, 구조 등은 **미리 정의된 프리셋**에서 선택/조립한다.
매번 새로 생성하는 것이 아니라, 기술 스택과 프로젝트 카테고리에 따라 최적의 조합을 가져다 쓴다.

**프리셋 저장소:**

```
harness/
├── conventions/           # 기술 스택별 컨벤션 (미리 정의)
│   ├── react-typescript.md
│   ├── spring-boot.md
│   ├── vue-typescript.md
│   └── ...
├── toolsets/              # 카테고리별 하네스 도구 조합 (미리 정의)
│   ├── webapp-frontend.md     (ESLint + Prettier + Vitest + Husky)
│   ├── webapp-backend-java.md (Checkstyle + JUnit + Gradle)
│   └── ...
└── templates/             # Phase 템플릿 (미리 정의)
    └── phase-webapp.md
```

**입력:**
- `docs/analysis.md` (기술 스택, 범위)
- `docs/design.md` (설계안)
- `harness/conventions/` (프리셋)
- `harness/toolsets/` (프리셋)
- `harness/templates/` (프리셋)

**동작:**
1. `analysis.md`에서 기술 스택 확인 → `conventions/`에서 해당 블록 선택
2. 프로젝트 카테고리 확인 → `toolsets/`에서 해당 블록 선택
3. 선택된 블록들을 조립 → **CLAUDE.md**
4. `design.md` + `templates/` → **PROMPT.md** 생성

**출력:**
- `CLAUDE.md` — 프리셋에서 **조립** (컨벤션, 도구, 구조)
- `PROMPT.md` — 설계안 기반으로 **생성** (Phase별 작업 지시)

---

## 5. 하네스 프리셋

### 5.1 프리셋이란
기술 스택별 컨벤션, 카테고리별 도구 조합, Phase 템플릿 등
프로젝트마다 반복되는 설정을 미리 정의해둔 블록.

### 5.2 프리셋 종류

| 프리셋 | 위치 | 용도 | 예시 |
|--------|------|------|------|
| 컨벤션 | `harness/conventions/` | 기술 스택별 개발 규칙 | react-typescript.md, spring-boot.md |
| 도구 조합 | `harness/toolsets/` | 카테고리별 하네스 도구 세트 | webapp-frontend.md, webapp-backend-java.md |
| Phase 템플릿 | `harness/templates/` | 프로젝트 유형별 Phase 구조 | phase-webapp.md |

### 5.3 프리셋 사용 흐름

```
analysis.md의 기술 스택: React + TypeScript, Spring Boot
                               │
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                    ▼
  conventions/          toolsets/            templates/
  react-typescript.md   webapp-frontend.md   phase-webapp.md
  spring-boot.md        webapp-backend-java.md
          │                    │                    │
          └────────────────────┼────────────────────┘
                               ▼
                         CLAUDE.md (조립)
```

---

## 6. Subagents

| Agent | 역할 | 모델(예시) |
|-------|------|-----------|
| 요구사항 분석 agent | requirements.md → 구조화된 분석 결과 | Opus |
| 토론 Agent A | 급진적 페르소나, 혁신적 설계안 | Opus |
| 토론 Agent B | 논리적 페르소나, 안정적 설계안 | Sonnet / 다른 모델 |
| 사회자 Agent | A/B 판정 + 제3안 + 최적안 선정 | Opus |
| 산출물 조립/생성 agent | 프리셋 조립(CLAUDE.md) + 생성(PROMPT.md) | Opus |

---

## 7. Hooks

| Hook | 트리거 시점 | 역할 |
|------|-----------|------|
| 검증 hook | 각 Phase 완료 시 | 빌드/테스트/린트 자동 실행 및 결과 확인 |
| 커밋 hook | Phase 완료 시 | 자동 커밋 (Conventional Commits 형식) |
| 개선 hook | 스프린트 완료 시 | 피드백 수집 → 가이드 승격/메모리 저장 |

---

## 8. 자기 개선 루프

두 가지 루프가 존재한다:

### 8.1 내부 루프 — `/review` (프로젝트 내 반복 개선)

하나의 프로젝트 안에서 개발 → 검토 → 하네스 수정 → 리팩토링을 반복한다.

```
/ralph-loop → 코드 v1
    ↓
/review → 코드 + 하네스 산출물 검토 → 개선점 식별
    ↓
PROMPT.md / design.md 수정
    ↓
/ralph-loop → 코드 v2 (리팩토링)
    ↓
/review → "문제 없음" → 프로젝트 완료
```

**검토 대상:**
- 코드 품질 (빌드/테스트/린트, 구조, 중복, 요구사항 충족)
- 하네스 산출물 (PROMPT.md Phase 적절성, design.md 설계 적합성)

**산출물:**
- `docs/review/code-review.md` — 코드 리뷰 결과
- `docs/review/harness-review.md` — 하네스 산출물 리뷰
- `docs/review/improvement-plan.md` — 개선 계획
- `docs/review/lessons.md` — 교훈 기록 (누적, 외부 루프의 입력이 됨)

**핵심 원칙:**
- `/review`는 직접 코드를 수정하지 않는다. 하네스 산출물만 수정한다.
- 코드 수정은 항상 Ralph Loop을 통해 이루어진다.

### 8.2 외부 루프 — `/lesson-learn` (프리셋 반영)

프로젝트 완료 후, 내부 루프에서 쌓인 교훈을 하네스 프리셋에 반영한다.

```
프로젝트 A 완료 → /lesson-learn
    ↓
교훈 분류:
  ├─ 범용적 교훈 → 프리셋(harness/)에 반영
  ├─ 프로젝트 특수적 → 스킵
  └─ 판단 보류 → 메모리 저장, 다음 프로젝트에서 재확인
    ↓
프로젝트 B → 개선된 프리셋으로 시작
```

**반영 대상:**
| 교훈 카테고리 | 반영 위치 |
|-------------|----------|
| `prompt` | `harness/templates/` |
| `design` | `/debate` skill |
| `code` | `harness/conventions/` |
| `tooling` | `harness/toolsets/` |

### 8.3 두 루프의 관계

```
┌─────────────────────────────────────────────────┐
│ 프로젝트                                         │
│                                                  │
│  /analyze → /debate → /generate                  │
│       ↓                                          │
│  ┌──────────────────────────┐                    │
│  │ 내부 루프                 │                    │
│  │ /ralph-loop → /review ──┤← 반복               │
│  │      ↑          │       │                     │
│  │      └──────────┘       │                     │
│  │         교훈 누적 →      │→ docs/review/       │
│  └──────────────────────────┘   lessons.md        │
│                                     │            │
└─────────────────────────────────────│────────────┘
                                      ↓
                               /lesson-learn
                                      ↓
                               harness/ 프리셋 개선
                                      ↓
                               다음 프로젝트에서 활용
```

---

## 9. FDE 워크플로우 (목표 상태)

```bash
# 1. FDE가 요구사항서를 작성하여 프로젝트에 배치
docs/requirements.md

# 2. 분석 → 토론 → 산출물 생성
/analyze                    # What: 뭘 만들어야 하나
/debate                     # How: 어떻게 만들 것인가 (멀티에이전트 토론)
/generate                   # Execute: CLAUDE.md 조립 + PROMPT.md 생성

# 3. 개발 + 내부 개선 루프
/ralph-loop "PROMPT.md를 참고하여 개발을 진행하라" --completion-promise "DONE"
/review                     # 코드 + 하네스 검토 → 개선점 반영
/ralph-loop "..."           # 리팩토링 (필요 시 반복)

# 4. 프로젝트 완료 후 외부 개선 루프
/lesson-learn               # 교훈을 프리셋에 반영 → 다음 프로젝트 개선
```

---

## 10. 전체 Skill 목록

| Skill | 역할 | 유형 |
|-------|------|------|
| `/analyze` | 요구사항 분석 (What) | 파이프라인 |
| `/debate` | 멀티에이전트 설계 토론 (How) | 파이프라인 |
| `/generate` | 산출물 조립+생성 (Execute) | 파이프라인 |
| `/review` | 내부 개선 루프 (프로젝트 내 반복) | 개선 루프 |
| `/lesson-learn` | 외부 개선 루프 (프리셋 반영) | 개선 루프 |

Skill 파일 위치: `.claude/commands/`

---

## 11. 미결정 / 추후 논의

### 완료된 것
- [x] 파이프라인 구조 설계 (analyze → debate → generate → ralph)
- [x] 3개 파이프라인 skill 상세 설계 + 구현
- [x] 프리셋 작성 (conventions, toolsets, templates)
- [x] 자기 개선 루프 설계 — 내부(/review) + 외부(/lesson-learn) + 구현

### 나중에 고민할 것
- [ ] 작업 유형 분류 (신규 설계 / 기존 수정 / 단순 작업 → 복잡도별 경로 분기)
- [ ] Brain 컨텍스트 (서비스 맥락, 고객 정보, 지표를 아는 중앙 컨텍스트)
- [ ] 에러 발생 시 복구 전략 (Ralph Loop 중 실패 시)
- [ ] 범용 확장 시 프로젝트 유형별 분기 방법
- [ ] 실제 프로젝트에서 전체 파이프라인 테스트 검증

---

## 변경 이력

| 날짜 | 내용 |
|------|------|
| 2026-04-10 | 최초 작성 — 프로세스 하네스 방향 논의 결과 정리 |
| 2026-04-10 | 멀티에이전트 토론(`/debate`)과 자기 개선 루프(lesson-learn) 추가 — Pluuug 사례 참고 |
| 2026-04-10 | 3개 skill 상세 설계 확정 — analyze(What) / debate(How) / generate(Execute, 프리셋 기반 조립) |
| 2026-04-10 | 프리셋 작성 완료 + 자기 개선 루프 2중 구조(내부/외부) 설계 + 5개 skill 구현 완료 |
