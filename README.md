# byul-fde-harness

FDE(Forward Deployed Engineer)를 위한 프로세스 하네스 환경.
요구사항서만 작성하면, 분석 → 설계 토론 → 산출물 생성 → 자동 개발까지 일관된 프로세스로 진행한다.

## 구조

```
.claude/
├── agents/              # 에이전트 정의 (누가 할 것인가)
│   ├── architect-radical.md
│   ├── architect-stable.md
│   ├── moderator.md
│   └── code-reviewer.md
└── skills/              # 워크플로우 (무엇을 할 것인가)
    ├── analyze/         /analyze — 요구사항 분석 (What)
    ├── debate/          /debate — 멀티에이전트 설계 토론 (How)
    ├── generate/        /generate — 프리셋 조립 + PROMPT.md 생성
    ├── review/          /review — 내부 개선 루프
    └── lesson-learn/    /lesson-learn — 외부 개선 루프

harness/
├── conventions/         # 기술 스택별 컨벤션
├── toolsets/            # 카테고리별 도구 조합
└── templates/           # Phase 템플릿 + 요구사항서 템플릿
```

## 워크플로우

```bash
# 1. 요구사항서 작성
docs/requirements.md

# 2. 파이프라인 실행
/analyze       # What: 뭘 만들어야 하나
/debate        # How: 멀티에이전트 토론으로 설계
/generate      # Execute: CLAUDE.md 조립 + PROMPT.md 생성

# 3. 자동 개발
/ralph-loop "PROMPT.md를 참고하여 개발을 진행하라" --completion-promise "DONE"

# 4. 내부 개선 루프
/review        # 코드 + 하네스 검토 → 개선 → 재실행

# 5. 외부 개선 루프 (프로젝트 완료 후)
/lesson-learn  # 교훈을 프리셋에 반영
```

## 현재 지원 프리셋

| 카테고리 | 프리셋 |
|---------|--------|
| Conventions | React + TypeScript, Spring Boot, Database |
| Toolsets | Webapp Frontend, Webapp Backend (Java) |
| Templates | Phase (Webapp), Requirements Template |
