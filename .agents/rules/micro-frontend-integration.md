---
trigger: always_on
description: Apply when adding features, making API calls, managing state, styling or routing, so the code integrates correctly with the cs-portal shell.
---

# Micro-Frontend Integration Guidelines

This application runs only as a micro-frontend inside the cs-portal shell, using
`@cloudscaile-eng/web-ext-utils` through `extensionManager` (`src/utils/extension.ts`).

## 1. Network requests

- **Rule**: Never create an axios client or use `fetch`.
- **Why**: The shell adds the user's token, signs the user out on a 401 and builds the gateway URL.
- **How**: `extensionManager.getExtAxios()`. Options: `open: true` for public endpoints,
  `host: true` for platform APIs, `type: 'py'` for a Python backend, `errorToast: true` for
  automatic error toasts. Never commit `local: true`.

## 2. State management (Redux)

- **Rule**: Never render a Redux `<Provider store={...}>`.
- **Why**: There is one store, owned by the shell.
- **How**: Create Redux Toolkit slices and inject them:
  `extensionManager.injectReducers({ mySlice: mySliceReducer }, [], ['mySlice'])`
  (reducers, keys to replace, keys to persist). Server data belongs in TanStack Query.

## 3. Theming and styling

- **Rule**: Never call `createTheme()` or hard-code colours.
- **Why**: Each tenant sets its own theme in the Designer; the extension must look native everywhere.
- **How**: `<ThemeProvider theme={extensionManager.getTheme()}>` (already in `App.tsx`) and theme
  tokens in `sx`.

## 4. Notifications

- **Rule**: Never install a toast library (`react-toastify`, `notistack`, ...).
- **How**: `extensionManager.toast('Message', 'success' | 'error' | 'info')`.

## 5. Routing

- **Rule**: Never use `<BrowserRouter>` or `<Routes>`.
- **Why**: The shell owns the URL and mounts exposed modules on routes configured in the Designer.
- **How**: `useNavigate` and `useParams` work through the shared `react-router` singleton. Take base
  paths as props with defaults.

## 6. Events between extensions

- **How**: `extensionManager.getEventBus()` with `on` and `emit`. There is no `off`, so subscribe
  once at module scope and prefix event names with your extension name.
