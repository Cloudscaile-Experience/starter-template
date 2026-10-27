# Starter Template — Frontend (Micro-Frontend)

Guidance for AI coding assistants working in `web/`.

## Project overview

React 19 micro-frontend built with TypeScript, Webpack 5 Module Federation, MUI v7, TanStack
Query and react-i18next. It exposes one module, `./HelloWorld`, which the cs-portal shell loads
from `remoteEntry.js` at runtime and mounts into a grid slot on a page built in the Designer. It is
**never** the root application.

Shell services (HTTP, store, theme, toasts, i18n, auth, analytics) come from
`@cloudscaile-eng/web-ext-utils`, wrapped once in `src/utils/extension.ts` (`extensionManager`).

Read before changing code:

- `README.md`: structure, Module Federation contract, `ExtensionManager`, `getExtAxios` options
- `.claude/skills/`: architecture, integration, coding standards, design, and task recipes

## Commands

```sh
npm install
APP_PORT=3001 npm start     # dev server; APP_PORT must be exported in the shell
npm run build               # production build into dist/
npm run check               # Biome lint + format
npm run check:fix
npm run type-check          # tsc --noEmit
```

Run `npm run check` and `npm run type-check` before finishing a change.

## Hard rules

1. All shell services go through `extensionManager`. Never import axios directly, call `fetch`,
   render a Redux `<Provider>`, call `createTheme()`, add a toast library, or render
   `<BrowserRouter>`/`<Routes>`.
2. Keep the `TENANT_NAME` and `EXTENSION_NAME` fallbacks in `src/utils/appConfig.ts` equal to the
   extension's `tenant` and `extensionName`. The platform build does not set these variables.
3. Keep the keys in `exposes` (`webpack/webpack.common.cjs`) in sync with the modules the extension
   declares, and the federation `name` equal to its scope (`remote`).
4. Every exposed module default-exports a component wrapped in `<App>`, and every prop has a
   default, because the shell only passes the Props JSON set in the Designer.
5. All user-facing text goes through `t()` with a namespace from `getNsForTranslation()`.
   Locale JSON is keyed by language: `{ "en": { ... } }`.
6. Never commit `getExtAxios({ local: true })`; it sends production traffic to localhost.
7. Use theme tokens (`primary.main`, `text.secondary`) in `sx`; never hex colours. Each tenant has
   its own theme.
8. Use npm only and keep `package-lock.json` committed; the platform build runs
   `npm ci --ignore-scripts` then `npm run build`.

## Good to know

- Keep `@cloudscaile-eng/web-ext-utils` at the version cs-portal uses (currently `^0.0.8`).
  `^0.0.x` ranges never update by themselves, so bump deliberately.
- `getOAuthProviders()` is async. `getUser()` returns `{ data, authenticated, isGuestUser, browserId }`.
- The event bus has `on` and `emit` but no `off`: subscribe once, at module scope.
- Analytics calls (`trackGA4Event`, `trackGTMEvent`) are no-ops until the user accepts cookies,
  unless the tenant enables Skip consent.
- For a Python backend, set `type: 'py'` once inside `ExtensionManager.getExtAxios()`.
- Opening the dev server directly shows nothing useful: `getTheme()` throws until a host has
  called `initializeHost()`. Test through a local cs-portal.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`).
