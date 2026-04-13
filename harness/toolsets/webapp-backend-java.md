# Webapp Backend Java Toolset

## Build Tool
- **Gradle** with Kotlin DSL (`build.gradle.kts`)
- Java toolchain: 21

## Project Generation
- Spring Initializr (`start.spring.io`)
- Parameters:
  - Type: `gradle-project-kotlin`
  - Language: `java`
  - Spring Boot: 3.x (latest stable)
  - Dependencies: `web`, `data-jpa`, `postgresql`, `h2`, `validation`

## Linting / Code Style
- **Checkstyle** (Gradle plugin)
- Config: `config/checkstyle/checkstyle.xml`
- Rules:
  - Naming: TypeName, MethodName, ConstantName, LocalVariableName, MemberName, ParameterName, PackageName
  - Imports: AvoidStarImport, UnusedImports, RedundantImport
  - Whitespace: WhitespaceAround, NoWhitespaceBefore
  - Blocks: NeedBraces, LeftCurly, RightCurly
  - Misc: UpperEll, ArrayTypeStyle
  - FileLength max: 500
- Script: `./gradlew checkstyleMain`

## Testing
- **JUnit 5** (via `spring-boot-starter-test`)
- **MockMvc** for controller integration tests
- `@SpringBootTest` + `@AutoConfigureMockMvc`
- `@BeforeEach` for test isolation (data cleanup)
- Script: `./gradlew test`

## Database
- Dev profile (`dev`): H2 in-memory
  - URL: `jdbc:h2:mem:{projectname}`
  - Console: enabled at `/h2-console`
  - DDL: `create-drop`
- Prod profile (`prod`): PostgreSQL
  - Credentials via env vars: `${DB_USERNAME}`, `${DB_PASSWORD}`
  - DDL: `validate`
- Default active profile: `dev`

## Build Scripts
```bash
./gradlew build          # Compile + checkstyle + test
./gradlew test           # Tests only
./gradlew checkstyleMain # Checkstyle only
./gradlew bootRun        # Run dev server
```

## Gradle Plugins
```kotlin
plugins {
    java
    checkstyle
    id("org.springframework.boot") version "3.x.x"
    id("io.spring.dependency-management") version "1.x.x"
}
```

## Known Issues
- **Windows file lock**: Gradle daemon may lock `build/` directory. Run `./gradlew --stop` then `rm -rf build` before retry
- **H2 + JPA**: `@Lob` with `columnDefinition = "TEXT"` needed for long text fields to work consistently across H2 and PostgreSQL
