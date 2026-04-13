# Phase Template: Webapp

> 이 템플릿은 /generate가 PROMPT.md를 생성할 때 사용하는 Phase 구조 기본 틀이다.
> 각 Phase의 세부 작업은 design.md의 설계안에 따라 구체화된다.

## Phase 구조

### Phase 1: 프로젝트 초기화

**작업:**
- Git 레포 초기화
- `.gitignore` 생성 (Node.js + Backend 언어 + IDE)
- 모노레포 디렉토리 구조 생성 (`frontend/`, `backend/`, `docs/`)
- 루트 `README.md` 작성

**완료 조건:**
- `git status` 정상 동작
- 디렉토리 구조가 CLAUDE.md 정의대로 존재
- `.gitignore` 적절히 설정됨

---

### Phase 2: Frontend 하네스

**작업:**
- FE 프로젝트 생성 (toolset에 따라)
- 린트 설정
- 포맷터 설정
- 테스트 프레임워크 설정 + 샘플 테스트
- Git hooks 설정 (루트 레벨)
- 개발 서버 실행 확인

**완료 조건:**
- `npm run dev` → 로컬 서버 정상 실행
- `npm run lint` → 에러 없음
- `npm run format:check` → 에러 없음
- `npm run test` → 테스트 통과
- Git commit 시 pre-commit hook 동작

---

### Phase 3: Backend 하네스

**작업:**
- BE 프로젝트 생성 (toolset에 따라)
- 코드 스타일 검사 설정
- 테스트 프레임워크 설정 + 샘플 테스트
- DB 연결 설정 (개발용 + 운영용 프로필)
- 서버 실행 확인

**완료 조건:**
- 빌드 성공
- 테스트 통과
- 코드 스타일 검사 통과
- 서버 정상 기동

---

### Phase 4: FE ↔ BE 통합 + 공통 레이아웃

**작업:**
- BE: Health Check API 생성
- FE: API 호출 유틸리티 설정
- FE → BE API 호출 확인
- CORS 설정
- 공통 레이아웃 구현 (design.md 기반)
  - 헤더 (네비게이션, 활성 메뉴 표시)
  - 푸터 (회사/서비스 정보)
- 라우터 설정 (design.md의 화면 구조 반영)
- 루트 레벨 스크립트 (전체 빌드/테스트)

**완료 조건:**
- FE에서 BE API 호출 성공
- CORS 정상 동작
- 헤더/푸터가 모든 페이지에 공통 표시
- 라우팅 정상 동작
- 루트에서 전체 빌드/테스트 가능

---

### Phase 5~N: 요구사항별 기능 구현

> 이 Phase는 design.md의 설계안에 따라 동적으로 생성된다.
> /generate가 설계안의 기능 단위를 Phase로 분리한다.

**Phase 분리 기준:**
- BE API와 FE UI를 하나의 기능 단위로 묶을 수 있으면 같은 Phase
- 독립적인 기능이면 별도 Phase로 분리
- 의존 관계가 있으면 의존되는 쪽이 먼저

**각 기능 Phase의 공통 구조:**

```
### Phase N: [기능명]

**BE 작업:**
- Entity / Repository / Service / Controller
- API 엔드포인트 (design.md 참조)
- 유효성 검사
- 테스트

**FE 작업:**
- 페이지 컴포넌트 (design.md 참조)
- API 연동
- 유효성 검사 (클라이언트)
- 예외 처리 (에러/빈 상태 안내)
- 테스트

**완료 조건:**
- BE: API 정상 동작 + 테스트 통과
- FE: UI 정상 동작 + 테스트 통과
- 린트/포맷 검사 통과
```

---

## 매 반복(Ralph Loop)마다 수행할 것

1. 현재 프로젝트 상태 확인 (파일 구조, git log, 테스트 결과)
2. 어떤 Phase의 어떤 작업까지 완료되었는지 판단
3. 다음 미완료 작업 진행
4. 작업 후 완료 조건 검증 (빌드, 테스트, 린트)
5. 진행 상황을 `docs/progress.md`에 기록
6. 각 Phase 완료 시 git commit (Conventional Commits)

## 완료 신호

모든 Phase의 완료 조건이 충족되면:

```
<promise>DONE</promise>
```
