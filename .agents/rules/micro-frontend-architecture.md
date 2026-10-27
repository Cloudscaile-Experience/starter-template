---
trigger: always_on
description: How this micro-frontend reaches shell (host) services through @cloudscaile-eng/web-ext-utils, and the Module Federation contract it must honour.
---

# Micro-Frontend Architecture using @cloudscaile-eng/web-ext-utils

## How it works

- The cs-portal shell calls `initializeHost({...})` once, before any remote loads. It stores its
  services (axios factory, Redux store, theme, auth functions, analytics, and so on) on
  `window.__MF_SHARED_RESOURCES__`.
- This extension reads them with plain getter functions. There are no React hooks or providers in
  the package.
- Every getter takes an `Extension` object created once with `getExtension(tenant, name)`. In this
  project that is done inside `ExtensionManager` (`src/utils/extension.ts`); always call
  `extensionManager.*` rather than the raw functions.

```typescript
import { getExtension, getTheme } from '@cloudscaile-eng/web-ext-utils';

const extension = getExtension(APP_CONFIG.TENANT_NAME, APP_CONFIG.EXTENSION_NAME);
const theme = getTheme(extension);
```

## Available functions (v0.0.8)

Keep the package at the same version as cs-portal.

| Capability | Functions |
|------------|-----------|
| HTTP | `getExtAxios(extension, config)` |
| State | `getReduxStore(extension)`, `injectReducers(extension, { reducers, replace, whitelist })` |
| UI | `getTheme(extension)`, `toast(extension, message, 'success' \| 'error' \| 'info' \| 'warn')` |
| i18n | `registerTranslation(extension, { ns, translation })`, `getNsForTranslation(extension, ns)` |
| User and roles | `getUser(extension)` → `{ data, authenticated, isGuestUser, browserId }`, `validateUserPermission(extension, keys)` → `{ [key]: boolean }` |
| Auth | `triggerLogin(extension, { redirect?, provider?, email?, password? })`, `triggerGuestLogin`, `triggerLogout`, `getOAuthProviders` (async), `triggerSendOTP`, `triggerSignUp` |
| Consent and analytics | `getCookieConsent`, `updateCookieConsent`, `resetCookieConsent`, `trackGA4Event`, `trackGTMEvent` |
| Events | `getEventBus(extension)` → `{ on, emit }` (no `off`) |

## Module Federation contract

- The federation `name` equals `manifest.json` `web.scope` (`remote`); the shell reads `window[scope]`.
- `filename` is `remoteEntry.js`.
- Keys in `exposes` match `manifest.json` `web.modules[].module` exactly.
- Each exposed module default-exports a React component (the shell renders it with `React.lazy`).
- `react`, `react-dom`, `react-router`, `i18next` and `react-i18next` are shared as singletons.
  MUI, Redux Toolkit, React Query and axios are bundled per extension and reach the shell through
  the functions above.
- The shell only passes the Props JSON set in the Designer, so every prop needs a default.

## Error handling

- Getters throw `Resource not found` if the host never called `initializeHost()`. This happens when
  the dev server is opened directly; test through a local cs-portal.
- `getExtension` throws if the tenant or name is missing.
