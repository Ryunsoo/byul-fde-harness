# Webapp Frontend Toolset

## Build Tool
- **Vite** (latest)
- Template: `react-ts`
- Dev server proxy: `/api` → `http://localhost:8080`

## Linting
- **ESLint** (flat config, `eslint.config.js`)
- Plugins: `@eslint/js`, `typescript-eslint`, `eslint-plugin-react-hooks`, `eslint-plugin-react-refresh`
- Prettier integration: `eslint-plugin-prettier` + `eslint-config-prettier`
- Script: `npm run lint`

## Formatting
- **Prettier**
- Config (`.prettierrc`):
  ```json
  {
    "semi": false,
    "singleQuote": true,
    "trailingComma": "all",
    "printWidth": 80,
    "tabWidth": 2,
    "endOfLine": "auto"
  }
  ```
- Scripts: `npm run format`, `npm run format:check`

## Testing
- **Vitest**
- Environment: `jsdom`
- Libraries: `@testing-library/react`, `@testing-library/jest-dom`
- Setup file: `src/test/setup.ts` (imports `@testing-library/jest-dom`)
- Config in `vite.config.ts`:
  ```typescript
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    pool: 'threads',        // Required on Windows
    testTimeout: 30000,
  }
  ```
- Scripts: `npm run test` (single run), `npm run test:watch` (watch mode)

## Git Hooks (root level)
- **Husky** + **lint-staged**
- Install at monorepo root (`package.json`)
- Pre-commit hook (`.husky/pre-commit`):
  ```bash
  # 1. lint-staged (staged 파일 대상 prettier + eslint)
  npx lint-staged --no-stash || exit 1

  # 2. 타입 체크 (TS 변경 시에만)
  if git diff --cached --name-only | grep -qE '^frontend/.*\.(ts|tsx)$'; then
    (cd frontend && npx tsc --noEmit) || exit 1
  fi
  ```
- lint-staged config (root `package.json`):
  ```json
  {
    "lint-staged": {
      "frontend/src/**/*.{ts,tsx}": [
        "prettier --check",
        "frontend/node_modules/.bin/eslint --config frontend/eslint.config.js --max-warnings=0"
      ],
      "frontend/src/**/*.css": [
        "prettier --check"
      ]
    }
  }
  ```
- Prettier must be installed at root level as well
- ESLint는 root에 설치하지 않는다. frontend의 바이너리를 직접 참조한다.
- `--no-stash` 옵션 필수: untracked 파일이 많은 모노레포에서 stash 충돌 방지
- 타입체크는 TS 파일이 staged 되어 있을 때만 실행하여 속도 최적화

## Package Scripts
```json
{
  "dev": "vite",
  "build": "tsc -b && vite build",
  "lint": "eslint .",
  "format": "prettier --write \"src/**/*.{ts,tsx,css}\"",
  "format:check": "prettier --check \"src/**/*.{ts,tsx,css}\"",
  "test": "vitest run",
  "test:watch": "vitest",
  "preview": "vite preview"
}
```

## Known Issues
- **Prettier + CRLF (Windows)**: Must set `"endOfLine": "auto"` in both root and frontend `.prettierrc`
- **Vitest worker timeout (Windows)**: Must set `pool: "threads"` in vite test config
- **lint-staged + prettier**: Prettier must be installed at monorepo root, not just in frontend
- **lint-staged + eslint**: ESLint는 root에 설치하지 말고 `frontend/node_modules/.bin/eslint`로 직접 참조. `--config frontend/eslint.config.js` 필수
- **lint-staged stash 충돌**: untracked 파일이 많으면 stash 실패. `--no-stash` 옵션으로 해결
