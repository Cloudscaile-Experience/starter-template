# CLAUDE.md

Guidance for AI coding assistants working in this repository.

## What this is

A Cloudscaile **web extension** template: a React 19 micro-frontend (`web/`) exposed over Webpack
Module Federation, plus an Express backend (`js/`). The cs-portal shell loads `remoteEntry.js` at
runtime and mounts exposed modules into grid slots on pages built in the Designer. The web app is
**never** the root application.

Read before changing code:

- `README.md`: manifest fields, local setup, packaging and the Designer flow
- `web/README.md`: web structure, Module Federation contract, `ExtensionManager`
- `.agents/rules/`: always-on rules (architecture, integration, coding standards, design)
- `.agents/skills/`: task recipes (translations, reducers, shared axios, MUI, new modules, packaging)

## Commands

```sh
# web/
npm install
APP_PORT=3001 npm start     # dev server; APP_PORT must be exported
npm run build               # production build into dist/
npm run check               # Biome lint + format
npm run check:fix
npm run type-check          # tsc --noEmit

# js/
npm install
npm start                   # Express on PORT (default 8000)

# repo root
./build.sh                  # zips the last commit into cloudscaile.<extensionName>.zip
```

Run `npm run check` and `npm run type-check` in `web/` before finishing a change.

## Hard rules

1. All shell services go through `extensionManager` (`web/src/utils/extension.ts`), which wraps
   `@cloudscaile-eng/web-ext-utils`. Never import axios directly, call `fetch`, render a Redux
   `<Provider>`, call `createTheme()`, add a toast library, or render `<BrowserRouter>`/`<Routes>`.
2. Keep identity in sync: `manifest.json` (`tenant`, `extensionName`), the fallbacks in
   `web/src/utils/appConfig.ts`, and `FINAL_ZIP_NAME` in `build.sh`.
3. Keep `exposes` in `web/webpack/webpack.common.cjs` one-to-one with `manifest.json`
   `web.modules[].module`. The federation `name` stays equal to `web.scope`.
4. Every exposed module default-exports a component wrapped in `<App>` (theme + query client), and
   every prop has a default value, because the shell only passes the Props JSON set in the Designer.
5. All user-facing text goes through `t()` with a namespace from `getNsForTranslation()`.
   Locale JSON is keyed by language: `{ "en": { ... } }`.
6. Never commit `getExtAxios({ local: true })`; it sends production traffic to localhost.
7. Use theme tokens (`primary.main`, `text.secondary`) in `sx`; never hex colours. Each tenant has
   its own theme.
8. Use npm only. Keep `package-lock.json` committed; the platform build runs
   `npm ci --ignore-scripts` then `npm run build`.

## Good to know

- `@cloudscaile-eng/web-ext-utils` must match the version cs-portal uses (currently `^0.0.8`).
  `^0.0.x` ranges never update by themselves, so bump deliberately.
- `getOAuthProviders()` is async. `getUser()` returns `{ data, authenticated, isGuestUser, browserId }`.
- The event bus has `on` and `emit` but no `off`: subscribe once, at module scope.
- Analytics calls (`trackGA4Event`, `trackGTMEvent`) are no-ops until the user accepts cookies,
  unless the tenant enables Skip consent.
- For a Python backend, set `type: 'py'` once inside `ExtensionManager.getExtAxios()`.
- `build.sh` uses `git archive HEAD`: only committed files are packaged.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`).
