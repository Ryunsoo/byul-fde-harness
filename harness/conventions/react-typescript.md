# React + TypeScript Convention

## Language & Framework
- React 19+ with functional components + hooks
- TypeScript strict mode
- JSX/TSX for component files

## Project Structure
```
frontend/
├── src/
│   ├── api/           # API client and endpoint functions
│   ├── components/    # Shared/common components
│   ├── pages/         # Route-level page components
│   ├── test/          # Test setup files
│   ├── App.tsx        # Root component with router
│   ├── main.tsx       # Entry point
│   └── index.css      # Global styles
├── public/            # Static assets
└── index.html         # HTML entry
```

## Component Rules
- Functional components only (no class components)
- One component per file, file name matches component name
- Use `export default` for page components
- Use named exports for shared components when multiple exports exist
- Props interface defined in the same file as the component

## Naming Conventions
- Components: PascalCase (`BoardListPage.tsx`)
- Hooks: camelCase with `use` prefix (`useAuth.ts`)
- Utilities: camelCase (`formatDate.ts`)
- CSS files: same name as component (`Header.css`)
- Test files: `*.test.tsx` alongside source files

## State Management
- React built-in state (useState, useReducer) for local state
- Props drilling for shallow component trees
- Context API for cross-cutting concerns only when needed

## Routing
- React Router v6+ with `BrowserRouter`
- Route definitions in `App.tsx`
- Use `<NavLink>` for navigation with active state

## Styling
- CSS files per component (co-located)
- CSS custom properties (variables) in `index.css` for design tokens
- No CSS-in-JS unless project requires it

## API Communication
- Fetch API wrapper in `api/client.ts`
- Each domain has its own API module (`api/posts.ts`)
- Use Vite proxy (`/api` → backend) for development
- Relative paths in API client (`/api/...`), not absolute URLs

## TypeScript
- Strict mode enabled
- Interfaces for data shapes (not types, unless union/intersection needed)
- No `any` — use `unknown` if type is genuinely unknown
- Export types/interfaces from API modules for reuse

## Error Handling
- API errors caught in page components
- User-facing error messages displayed in UI
- Loading states for async operations

## Known Issues & Workarounds
- **Windows CRLF**: Set `"endOfLine": "auto"` in `.prettierrc`
- **Vitest on Windows**: Set `pool: "threads"` in vite.config.ts test config
