# Database Convention

> 기술 스택(Java, Node 등)과 무관하게 적용되는 DB 설계/네이밍 규칙.

## Naming Rules

### Tables
- `snake_case`, 복수형
- 예: `posts`, `users`, `comments`
- 연결 테이블: `{테이블A}_{테이블B}` (예: `user_roles`)

### Columns
- `snake_case`
- 예: `created_at`, `view_count`, `is_active`
- boolean 컬럼: `is_` 또는 의미가 명확한 형용사 (예: `is_active`, `verified`)

### Primary Key
- 단일 컬럼 `id` (auto increment 또는 identity)
- 타입: `BIGINT` (대부분의 경우)

### Foreign Key
- `{참조 테이블 단수형}_id`
- 예: `post_id`, `user_id`

### Index
- `idx_{테이블}_{컬럼}`
- 예: `idx_posts_created_at`
- Unique index: `uq_{테이블}_{컬럼}`
- 예: `uq_users_email`

### Constraint
- Primary key: `pk_{테이블}`
- Foreign key: `fk_{테이블}_{참조테이블}`
- 예: `fk_comments_posts`

## Common Columns

모든 테이블에 포함하는 공통 컬럼:

| Column | Type | Nullable | 설명 |
|--------|------|----------|------|
| `id` | BIGINT | NOT NULL | Primary key, auto increment |
| `created_at` | TIMESTAMP | NOT NULL | 생성 시각, 서버 시간 기준 |
| `updated_at` | TIMESTAMP | NULL | 수정 시각, 최초 생성 시 null |

## Soft Delete

물리 삭제 대신 soft delete를 기본으로 사용한다.

| Column | Type | Nullable | 설명 |
|--------|------|----------|------|
| `deleted_at` | TIMESTAMP | NULL | 삭제 시각. null이면 미삭제 |

- 조회 시: `WHERE deleted_at IS NULL`
- 삭제 시: `UPDATE ... SET deleted_at = NOW()`
- 복구 시: `UPDATE ... SET deleted_at = NULL`
- 완전 삭제가 필요한 경우에만 물리 삭제 (개인정보 등)

**왜 `deleted_at`인가:**
- 삭제 시점을 알 수 있어 운영/감사에 유용
- 일정 기간 후 자동 완전 삭제 정책 적용 가능
- boolean `deleted`보다 정보량이 많고, 비용 차이 없음

## Data Types

| 용도 | 권장 타입 | 비고 |
|------|----------|------|
| 식별자 | BIGINT | auto increment |
| 짧은 텍스트 | VARCHAR(N) | 제목, 이름 등 |
| 긴 텍스트 | TEXT | 본문 등 |
| 정수 | INT / BIGINT | 상황에 따라 |
| 소수 | DECIMAL(p,s) | 금액 등 정밀도 필요 시 |
| 날짜/시각 | TIMESTAMP | UTC 기준 권장 |
| boolean | BOOLEAN | PostgreSQL 네이티브 |

## Query Conventions

- SELECT 시 `*` 사용 지양, 필요한 컬럼만 명시 (ORM 사용 시 예외)
- 정렬 기본값: `ORDER BY created_at DESC` (최신순)
- 페이지네이션: `LIMIT` + `OFFSET` 또는 커서 기반

## JPA/ORM Mapping Notes

- Entity 클래스명: 단수형 PascalCase (`Post`, `User`)
- 테이블 매핑: `@Table(name = "posts")` — 복수형 snake_case
- 컬럼 매핑: JPA 기본 네이밍 전략이 `camelCase` → `snake_case` 변환 (Spring Boot 기본)
- `deleted_at`은 `LocalDateTime` 타입으로 매핑, null 허용
