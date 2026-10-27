---
name: universal-coding-standards
description: Universal coding standards for every file in this micro-frontend project. Covers npm conventions, TypeScript, Biome, commit discipline, and architecture patterns. Read this before touching any file.
---

# Micro-Frontend — Agent Coding Instructions

> These rules apply to **every file** in this project.
> This is a micro-frontend application that runs within a larger host application.

---

## 1. Project Overview

```
web/                           ← frontend project root (Webpack 5 + React 19)
├── src/                       ← source code
├── webpack/                   ← common / dev / prod configs (Module Federation lives in common)
├── .claude/skills/            ← AI assistant skills (this file included)
├── CLAUDE.md                  ← AI assistant instructions
├── biome.json                 ← Biome lint + format config
├── package.json               ← npm scripts, dependencies
└── package-lock.json          ← npm lockfile (must be committed)
```

The extension's `manifest.json` and `build.sh` live one level up, next to the backend folder.

---

## 2. Package Manager — npm Only

**Never** use `pnpm` or `yarn` anywhere in this project. The project uses `npm`.

```bash
# ✅ Install a dependency
npm install react

# ✅ Install a dev dependency
npm install -D @types/node

# ✅ Run a script
npm run build
npm run check

# ❌ Never
pnpm install
yarn add
```

---

## 3. TypeScript

The project uses TypeScript. Ensure strict typing is followed.

### General rules

- Prefer `unknown` over `any`. If `any` is unavoidable, add a `// biome-ignore lint/suspicious/noExplicitAny: <reason>` comment.
- Never use non-null assertion (`!`) unless the value being non-null is structurally guaranteed and a comment explains why.
- Explicit return types on all exported functions — inference is fine for internal helpers.
- Prefix intentionally unused identifiers with `_`.

```typescript
// ✅
export function formatName(first: string, last: string): string {
  return `${first} ${last}`;
}

// ❌
export function formatName(first, last) {
  return `${first} ${last}`;
}
```

---

## 4. Biome (lint + format)

Biome replaces ESLint and Prettier. Its config is `web/biome.json`.

- `npm run check`: lint and format check.
- `npm run check:fix`: apply fixes and formatting.
- `npm run type-check`: `tsc --noEmit`.
- Style: single quotes, semicolons, no trailing commas, 2-space indent, 100-character lines.
- Never argue formatting with the formatter — format and move on.
- **`noConsole` is enabled.** Do not leave `console.log` in production code.

---

## 5. Module System & Import Order

- **Do NOT import `/index` files explicitly**. When importing from a component or directory that has an `index` file, just import the directory path.
- **Always** use path aliases (e.g., `@/components/`, `@/utils/`) instead of relative paths like `../` or `./` where applicable.

### Import Order

Maintain three groups, separated by blank lines, in every file:

```typescript
// 1. Third-party packages
import { useMemo } from 'react';

// 2. Shell bridge (@cloudscaile-eng/web-ext-utils via extensionManager)
import { extensionManager } from '@/utils/extension';

// 3. Local paths
import { formatDate } from '@/utils/date';
```

Use `type` imports for types that are erased at runtime:

```typescript
import type { Filter } from '@/types';
```

---

## 6. Naming Conventions

| Item                        | Convention             | Example                             |
| --------------------------- | ---------------------- | ----------------------------------- |
| Files & folders             | `camelCase`            | `userProfile.ts`, `extension.ts`    |
| React component folders     | `PascalCase`           | `ClinicalList/`, `Search/`          |
| React component files       | `PascalCase`           | `index.tsx` or `DashboardTable.tsx` |
| Exported functions          | `camelCase`            | `formatDate`, `getExtAxios`         |
| Exported classes            | `PascalCase`           | `ExtensionManager`                  |
| Exported types / interfaces | `PascalCase`           | `ProViewItem`, `Sort`               |
| Constants (module-level)    | `SCREAMING_SNAKE_CASE` | `SEARCH_CATEGORY`                   |
| Environment variables       | `process.env.*`        | `process.env.API_BASE_URL`          |

---

## 7. Environment Variables & Secrets

- **Never** hard-code API keys, tokens, or environment-specific URLs anywhere in source.
- Read env vars via the standard Webpack convention (`process.env.VARIABLE_NAME`).

---

## 8. Error Handling

- Never swallow errors silently (`catch (_) {}`). Always log or re-throw.
- Do not expose internal error messages to end users.
- Use `extensionManager.toast` to notify users of errors.

---

## 9. Git Hygiene

### Commit message format — Conventional Commits

```
<type>(<scope>): <short summary>
```

| Type       | When to use                          |
| ---------- | ------------------------------------ |
| `feat`     | New feature visible to users         |
| `fix`      | Bug fix                              |
| `chore`    | Build, tooling, dependency updates   |
| `refactor` | Code change with no behaviour change |
| `docs`     | Documentation only                   |

- One logical change per commit.

---

## 10. Pre-commit Checklist

Before every commit:

- [ ] `npm run check` — zero errors
- [ ] `npm run type-check` — passes
- [ ] `manifest.json` modules still match webpack `exposes`
- [ ] No `getExtAxios({ local: true })` left in source
- [ ] No `console.*` calls left in source
- [ ] No hard-coded secrets or API keys
- [ ] Commit message follows Conventional Commits format

---

## 11. Micro-Frontend Constraints (CRITICAL)

- **Routing:** Do NOT use `react-router-dom` (e.g., `<BrowserRouter>`, `<Routes>`). The host application controls the URL and routing. Components are exported and mounted by the host.
- **State Management:** Inject reducers via `extensionManager.injectReducers`. Do not create a separate Redux `<Provider store={...}>`.
- **API Calls:** Use `extensionManager.getExtAxios()` instead of standalone `axios` or `fetch`.
- **Theming:** Use `extensionManager.getTheme()` and pass it to a `<ThemeProvider>`. Do not define a custom Material-UI theme.
- **Toasts:** Use `extensionManager.toast()`.

---

## 12. Translations & i18n

Always use translations for user-facing text.

- **No direct text:** Never hardcode direct text in UI components.
- **Use namespaces:** Create translation namespaces using `extensionManager.getNsForTranslation(ns)` and register them with `extensionManager.registerTranslation(ns, translations)`.
- **React Hook:** Use `useTranslation(ns)` from `react-i18next` inside components to access translations.
