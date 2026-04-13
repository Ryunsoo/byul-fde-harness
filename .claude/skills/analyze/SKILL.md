---
name: analyze
description: 요구사항 분석 (What) — requirements.md를 읽고 기술 스택, 범위, 핵심 요구사항을 정리
allowed-tools: Read, Write, Grep, Glob, Agent, Bash
---

# /analyze — 요구사항 분석 (What)

요구사항서를 분석하여 "뭘 만들어야 하는가"를 정리하라.

## 입력

- `docs/requirements.md` — FDE가 작성한 요구사항서 (필수)
- FDE가 사전 지정한 기술 스택이 있으면 존중하고, 없으면 요구사항 특성에 맞게 추천하라.

## 작업

1. `docs/requirements.md`를 읽는다.
2. 다음을 추출/정리한다:
   - **프로젝트 개요**: 요구사항서의 핵심을 한줄로 요약
   - **기술 스택**: FDE가 지정한 항목은 그대로, 미지정 항목은 AI가 보완
   - **구현 범위**: 포함 항목(화면/기능 목록)과 제외 항목을 명확히 분리
   - **핵심 요구사항**: 개발에 직접 필요한 요구사항만 추출 (운영/정책 등 비개발 항목 제외)
3. 결과를 `docs/analysis.md`로 저장한다.

## 출력 형식

`docs/analysis.md`를 아래 형식으로 작성하라:

```markdown
# 프로젝트 분석 결과

## 1. 프로젝트 개요
(한줄 요약)

## 2. 기술 스택
| 영역 | 기술 | 지정 방식 |
|------|------|----------|
| Frontend | ... | FDE 지정 / AI 추천 |
| Backend | ... | FDE 지정 / AI 추천 |
| Database | ... | FDE 지정 / AI 추천 |

## 3. 구현 범위
### 포함
- (화면/기능 목록을 bullet으로 나열)

### 제외
- (명시적으로 제외된 항목)

## 4. 핵심 요구사항 요약
(요구사항서에서 개발에 직접 필요한 핵심만 추출하여 정리)
```

## 주의사항

- **설계하지 마라.** API, 데이터 모델, 라우팅 등 "어떻게 만들 것인가"는 이 단계에서 다루지 않는다. 그것은 `/debate`의 역할이다.
- 요구사항서에 모호한 부분이 있으면 가장 합리적인 해석을 선택하고, 그 판단을 명시하라.
- 출력 완료 후 `docs/analysis.md`가 정상 생성되었는지 확인하라.

## 산출물 커밋

출력 완료 후, `docs/analysis.md`를 git commit 한다:
```
git add docs/analysis.md
git commit -m "docs: add project analysis result"
```

## 완료 조건

- `docs/analysis.md` 파일이 생성됨
- 위 형식의 4개 섹션이 모두 포함됨
- 설계 내용(API, 모델 등)이 포함되어 있지 않음
- git commit 완료
