---
name: generate
description: 산출물 조립+생성 (Execute) — 프리셋에서 CLAUDE.md 조립, 설계안으로 PROMPT.md 생성
allowed-tools: Read, Write, Grep, Glob, Agent, Bash
---

# /generate — 산출물 조립 + 생성 (Execute)

확정된 설계를 실행 가능한 산출물(CLAUDE.md + PROMPT.md)로 변환하라.
CLAUDE.md는 프리셋에서 **조립**, PROMPT.md는 설계안 기반으로 **생성**한다.

## 입력

- `docs/analysis.md` — 기술 스택, 구현 범위
- `docs/design.md` — 확정된 설계안
- `harness/conventions/` — 기술 스택별 컨벤션 프리셋
- `harness/toolsets/` — 카테고리별 도구 조합 프리셋
- `harness/templates/phase-webapp.md` — Phase 템플릿

## 작업 1: CLAUDE.md 조립

1. `docs/analysis.md`에서 기술 스택을 확인한다.
2. 기술 스택에 맞는 프리셋을 선택한다:
   - Frontend 스택 → `harness/conventions/`에서 해당 파일 (예: `react-typescript.md`)
   - Backend 스택 → `harness/conventions/`에서 해당 파일 (예: `spring-boot.md`)
   - Database → `harness/conventions/database.md`
   - Frontend 도구 → `harness/toolsets/`에서 해당 파일 (예: `webapp-frontend.md`)
   - Backend 도구 → `harness/toolsets/`에서 해당 파일 (예: `webapp-backend-java.md`)
3. 선택된 프리셋의 핵심 내용을 조합하여 `CLAUDE.md`를 작성한다.

**CLAUDE.md 구조:**

```markdown
# {프로젝트명}

{프로젝트 한줄 설명 — analysis.md의 프로젝트 개요에서 가져옴}

## 기술 스택

| 영역 | 기술 | 빌드 도구 |
|------|------|-----------|
(analysis.md에서 가져옴)

## 레포 구조

(모노레포 구조 — design.md의 화면/컴포넌트 구조 반영)

## 개발 규칙

### 공통
(커밋 컨벤션, 코드 변경 후 테스트 확인, 린트 통과 등)

### Frontend
(conventions 프리셋에서 핵심 규칙 추출)

### Backend
(conventions 프리셋에서 핵심 규칙 추출)

## 하네스 도구

### Frontend
(toolsets 프리셋에서 도구 목록 추출)

### Backend
(toolsets 프리셋에서 도구 목록 추출)
```

**조립 원칙:**
- 프리셋의 모든 내용을 복사하지 않는다. CLAUDE.md에 필요한 **핵심 규칙만** 추출한다.
- 프리셋의 상세 내용(설정 코드, Known Issues 등)은 PROMPT.md의 Phase에서 참조한다.
- 해당하는 프리셋 파일이 없으면 analysis.md의 기술 스택을 기반으로 직접 작성한다.

## 작업 2: PROMPT.md 생성

1. `harness/templates/phase-webapp.md`를 읽는다.
2. Phase 1~4는 템플릿의 구조를 따르되, 해당 프리셋의 구체적 설정을 반영한다.
   - 예: Phase 2의 "FE 프로젝트 생성"은 toolset의 빌드 도구(Vite), 테스트(Vitest) 등을 구체적으로 명시
   - 예: Known Issues(Windows CRLF, Vitest threads 등)를 작업 항목에 포함
3. Phase 5~N은 `docs/design.md`의 설계안을 기능 단위로 분리하여 생성한다.
   - 각 Phase에 BE 작업(API, Entity, 테스트)과 FE 작업(페이지, 연동, 테스트)을 포함
   - design.md의 API 설계, 데이터 모델, 화면 구조를 그대로 반영
4. 각 Phase에 구체적인 완료 조건을 포함한다.
5. Ralph Loop 운영 규칙(매 반복 수행 사항, 완료 신호)을 포함한다.

**PROMPT.md 구조:**

```markdown
# {프로젝트명} 개발 프롬프트

> Ralph Loop에서 반복 실행된다.

## 목표
(analysis.md의 프로젝트 개요)

## 참고 문서
- CLAUDE.md, docs/analysis.md, docs/design.md

## 사이트 구조
(design.md의 화면 구조/라우팅)

## 작업 순서

### Phase 1: 프로젝트 초기화
(템플릿 기반 + 프리셋 반영)

### Phase 2: Frontend 하네스
(템플릿 기반 + toolset 프리셋의 구체적 설정 반영)

### Phase 3: Backend 하네스
(템플릿 기반 + toolset 프리셋의 구체적 설정 반영)

### Phase 4: FE ↔ BE 통합 + 공통 레이아웃
(템플릿 기반 + design.md의 공통 컴포넌트 반영)

### Phase 5~N: 요구사항별 기능
(design.md의 설계안을 기능 단위로 Phase 분리)

## 매 반복마다 수행할 것
(템플릿에서 가져옴)

## 완료 신호
<promise>DONE</promise>
```

## 출력

- `CLAUDE.md` — 프로젝트 루트에 생성
- `PROMPT.md` — 프로젝트 루트에 생성

## 주의사항

- CLAUDE.md는 **간결하게**. 프리셋 전체를 복사하지 말고 핵심만 추출하라.
- PROMPT.md는 **구체적으로**. Ralph Loop이 모호함 없이 실행할 수 있을 만큼 상세하게 작성하라.
- 프리셋에 없는 기술 스택이면 analysis.md의 정보를 기반으로 직접 작성하라.
- 생성 완료 후 두 파일이 정상 생성되었는지 확인하라.

## 산출물 커밋

출력 완료 후, 생성된 산출물을 git commit 한다:
```
git add CLAUDE.md PROMPT.md
git commit -m "docs: generate CLAUDE.md and PROMPT.md from harness"
```

## 완료 조건

- `CLAUDE.md` 파일이 프로젝트 루트에 생성됨
- `PROMPT.md` 파일이 프로젝트 루트에 생성됨
- CLAUDE.md에 기술 스택, 레포 구조, 개발 규칙, 하네스 도구가 포함됨
- PROMPT.md에 모든 Phase와 완료 조건이 포함됨
- PROMPT.md에 Ralph Loop 완료 신호가 포함됨
- git commit 완료
