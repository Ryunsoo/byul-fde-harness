# Spring Boot Convention

## Language & Framework
- Java 17+
- Spring Boot 3.x
- Gradle with Kotlin DSL (`build.gradle.kts`)

## Project Structure
```
backend/
├── src/main/java/com/{company}/{project}/
│   ├── config/         # Configuration classes (CORS, Web, etc.)
│   ├── controller/     # REST controllers
│   ├── dto/            # Request/Response DTOs
│   ├── entity/         # JPA entities
│   ├── repository/     # Spring Data JPA repositories
│   ├── service/        # Business logic
│   └── Application.java  # Main class
├── src/main/resources/
│   └── application.yml    # Configuration (multi-profile)
├── src/test/java/         # Tests
├── config/checkstyle/     # Checkstyle config
└── build.gradle.kts       # Build configuration
```

## Naming Conventions
- Classes: PascalCase (`PostController.java`)
- Methods/variables: camelCase
- Constants: UPPER_SNAKE_CASE
- Packages: lowercase (`com.byulsoft.board`)
- DTOs: `*Request`, `*Response` suffix
- Entities: singular noun (`Post`, not `Posts`)

## Architecture
- Controller → Service → Repository layered architecture
- Controllers handle HTTP only, no business logic
- Services are `@Transactional(readOnly = true)` by default, write methods override with `@Transactional`
- Constructor injection (no `@Autowired` on fields)

## REST API Design
- Base path: `/api/`
- Resource-oriented URLs (`/api/posts`, `/api/posts/{id}`)
- HTTP methods: GET(read), POST(create), PUT(update), DELETE(delete)
- Response codes: 200(ok), 201(created), 204(no content), 400(bad request), 404(not found)
- Pagination via Spring `Pageable` (query params: `page`, `size`)

## Entity Rules
- `@Entity` with `@Table` annotation
- `@Id` with `@GeneratedValue(strategy = GenerationType.IDENTITY)`
- Protected no-arg constructor for JPA
- Public constructor with required fields
- Soft delete via boolean `deleted` field (not physical delete)

## Validation
- Bean Validation annotations on DTOs (`@NotBlank`, `@Size`, etc.)
- `@Valid` on controller method parameters
- Global exception handler (`@RestControllerAdvice`) for validation errors

## Database Configuration
- Multi-profile: `dev` (H2 in-memory), `prod` (PostgreSQL)
- Default active profile: `dev`
- H2 console enabled in dev mode (`/h2-console`)
- DDL auto: `create-drop` for dev, `validate` for prod
- Production credentials via environment variables

## Testing
- `@SpringBootTest` + `@AutoConfigureMockMvc` for integration tests
- `@BeforeEach` to clean up data between tests
- Test all API endpoints: success + error cases
- Use `MockMvc` for HTTP layer testing

## Error Handling
- `@RestControllerAdvice` for global exception handling
- `IllegalArgumentException` → 404 (resource not found)
- `MethodArgumentNotValidException` → 400 (validation failure)
- Error response format: `{"field": "error message"}` or `{"error": "message"}`
