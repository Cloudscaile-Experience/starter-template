# Starter Template — Web (Micro-Frontend)

React 19 micro-frontend that exposes a `HelloWorld` module through Webpack 5 Module Federation.
The cs-portal shell loads `remoteEntry.js` at runtime and mounts the module into a grid slot. It is
never the root application.

See the [top-level README](../README.md) for packaging and the Designer upload flow.

AI coding assistants: see [CLAUDE.md](CLAUDE.md) and the skills in `.claude/skills/`.

---

## Tech stack

| Tool | Purpose |
|------|---------|
| **React 19** | UI library (shared singleton with the shell) |
| **TypeScript** | Typing (`tsc --noEmit` via `npm run type-check`) |
| **Webpack 5 + Module Federation** | Builds `remoteEntry.js` and the exposed modules |
| **MUI v7** | Components, styled with the host theme from `getTheme()` |
| **TanStack Query v5** | Server state and caching (one `QueryClient` per extension) |
| **react-i18next** | Translations registered into the host i18n instance |
| **Redux Toolkit** | Slices injected into the host store (no local `<Provider>`) |
| **@cloudscaile-eng/web-ext-utils** | Bridge to shell services: HTTP, store, theme, toast, i18n, auth, analytics |
| **Biome** | Linter and formatter |
| **Tailwind CSS v4** | Utility classes via PostCSS |

---

## Project structure

```
web/
├── src/
│   ├── api/
│   │   └── openApi.ts            # fetchOpenInit(): GET /open/init with getExtAxios({ open: true })
│   ├── components/
│   │   └── HelloWorld.tsx        # Exposed module (default export)
│   ├── hooks/
│   │   └── useHelloWorld.ts      # TanStack Query hook around fetchOpenInit
│   ├── locales/
│   │   └── hello.json            # { "en": { ... } } translation bundle
│   ├── utils/
│   │   ├── appConfig.ts          # TENANT_NAME / EXTENSION_NAME (fallbacks must match manifest.json)
│   │   └── extension.ts          # ExtensionManager singleton wrapping web-ext-utils
│   ├── App.tsx                   # ThemeProvider(getTheme()) + QueryClientProvider
│   ├── bootstrap.tsx             # Dev-only render
│   ├── index.css                 # Tailwind import
│   └── index.tsx                 # import('./bootstrap'): the async boundary Module Federation needs
├── env/
│   ├── .env.development
│   └── .env.production
├── public/
│   └── index.html
├── webpack/
│   ├── plugins/LoadEnv.cjs       # Bakes TENANT_NAME / EXTENSION_NAME into the bundle
│   ├── webpack.common.cjs        # Module Federation: name, exposes, shared singletons
│   ├── webpack.dev.cjs           # Dev server: port from APP_PORT, publicPath 'auto', CORS *
│   └── webpack.prod.cjs          # Production build into dist/
├── biome.json
├── postcss.config.cjs
└── tsconfig.json
```

---

## Module Federation

```js
new ModuleFederationPlugin({
  name: 'remote',                 // = manifest.json web.scope
  filename: 'remoteEntry.js',     // = manifest.json web.remoteFileName
  exposes: {
    './HelloWorld': './src/components/HelloWorld'
  },
  shared: { react, 'react-dom', 'react-router', i18next, 'react-i18next' }  // all singleton: true
});
```

The contract with the shell:

- The federation `name` equals the manifest `scope`; the shell reads `window[scope]`.
- Every key in `exposes` appears in the manifest's `web.modules[].module`, and vice versa.
- Every exposed module **default-exports** a React component. The shell renders it through
  `React.lazy`, which only uses the default export.
- The shell passes only the Props JSON set in the Designer, so **every prop needs a default**.
- MUI, Redux Toolkit, React Query and axios are **not** shared. You reach the shell's instances
  through `extensionManager` instead.

---

## Getting started

```sh
npm install
APP_PORT=3001 npm start     # serves http://localhost:3001/remoteEntry.js
```

`APP_PORT` must be exported in your shell. The `env/*` files are read by `dotenv-webpack` into the
bundle, not by the webpack config, so without it the dev server falls back to port 8080.

The dev server is only useful through a local cs-portal: point a grid slot's `url` at
`http://localhost:3001/remoteEntry.js`. Opened on its own, `getTheme()` throws because no host
has called `initializeHost()`.

---

## Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Dev server with HMR (needs `APP_PORT`) |
| `npm run build` | Production bundle into `dist/` (what the platform build runs) |
| `npm run build:dev` | Development bundle |
| `npm run analyze` | Production bundle with the bundle analyzer |
| `npm run check` | Biome lint and format check |
| `npm run check:fix` | Apply Biome fixes |
| `npm run type-check` | TypeScript check without emit |

---

## ExtensionManager

`src/utils/extension.ts` creates the `Extension` object once from `APP_CONFIG` and wraps every
web-ext-utils call, so the rest of the code calls `extensionManager.*`.

```ts
const { data } = await extensionManager.getExtAxios({ open: true }).get('/open/init');
const theme = extensionManager.getTheme();
extensionManager.toast('Saved', 'success');
```

`getExtAxios` options:

| Option | Base URL | Use it for |
|--------|----------|------------|
| (none) | `{APP_BASE_URL}/v1/extensions/access/{tenant}/{name}/{type}` | Signed-in calls to your backend |
| `open: true` | `{APP_BASE_URL}/v1/extensions/public/{tenant}/{name}/{type}` | Public endpoints |
| `host: true` | `{APP_BASE_URL}` | Platform APIs |
| `local: true` | `{APP_LOCAL_API_URL}` | Local debugging only. Never commit it. |
| `type` | `'js'` (default) or `'py'` | Which backend half to call |
| `errorToast: true` | | The shell shows the API error as a toast |

The shell adds the user's Bearer token and signs the user out on a `401`.

Keep `@cloudscaile-eng/web-ext-utils` at the same version as cs-portal (currently `^0.0.8`).

---

## Architecture constraints

| Concern | Rule |
|---------|------|
| **HTTP** | Never use `fetch` or create an axios instance. Use `extensionManager.getExtAxios()`. |
| **Redux** | Never render `<Provider store={...}>`. Use `extensionManager.injectReducers(reducers, replace, whitelist)`. |
| **Theming** | Never call `createTheme()` or hard-code colours. Wrap with `<ThemeProvider theme={extensionManager.getTheme()}>`. |
| **Toasts** | Never add a toast library. Use `extensionManager.toast()`. |
| **Routing** | Never use `<BrowserRouter>` or `<Routes>`. Use `useNavigate` / `useParams`; take base paths as props. |
| **Events** | `getEventBus()` has `on` and `emit` but no `off`. Subscribe once, at module scope. |

---

## Adding a module

1. Create a container in `src/` that default-exports a component wrapped in `<App>`.
2. Add it to `exposes` in `webpack/webpack.common.cjs`, for example `'./MyModule': './src/containers/MyModule'`.
3. Add a matching entry to `manifest.json` `web.modules` with `name`, `description`, `module` and `size`.
4. Give every prop a default value.

## Translations

Register bundles at module scope, before anything renders:

```ts
export const ns = extensionManager.getNsForTranslation('hello');   // tenant_extension_hello
extensionManager.registerTranslation(ns, helloTranslations);

const { t } = useTranslation(ns);
```

Locale files are keyed by language at the top level: `{ "en": { "title": "Hello World" } }`.

## Styling

- MUI `sx` or `styled()` with theme tokens (`primary.main`, `text.secondary`). No hex values.
- Layout with `Stack`, `Box` and `Grid`; text with `Typography`.
- Each tenant sets its own theme in the Designer's Style builder, so never assume specific colours.
