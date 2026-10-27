# Starter Template — Cloudscaile Web Extension

The smallest complete Cloudscaile extension: a **React 19 micro-frontend** exposed over
**Webpack Module Federation**, and a **Node/Express backend**. Copy this repository to start a new
extension, rename its identity, and ship one module end to end before adding features.

The extension never runs on its own. The **cs-portal** shell loads `remoteEntry.js` at runtime and
mounts the exposed module into a grid slot on a page that someone built in the **Designer**.

---

## Repository layout

```
starter-template/
├── manifest.json     # Identity, exposed modules and backend needs (read by the platform)
├── build.sh          # Packages the last commit into cloudscaile.<extensionName>.zip
├── web/              # React 19 remote: webpack 5 + Module Federation (see web/README.md)
├── js/               # Express backend, reached through the API gateway
├── CLAUDE.md         # Instructions for AI coding assistants
└── .agents/          # Shared rules and skills for AI coding assistants
```

## manifest.json

| Field | Meaning |
|-------|---------|
| `tenant`, `extensionName` | Your identity. Must match `APP_CONFIG` in `web/src/utils/appConfig.ts`. Both are part of your API path (`/v1/extensions/access/{tenant}/{name}/{type}`) and your translation namespace. |
| `displayName`, `description`, `version` | What the Designer shows in its Extensions list. |
| `web.scope` | Your Module Federation `name` (`remote`). The shell reads `window[scope]`. |
| `web.remoteFileName` | Always `remoteEntry.js`. |
| `web.modules[]` | One entry per key in webpack `exposes`. These are the tiles people drag onto pages in the Designer's **Frame** editor. |
| `web.modules[].size` | MUI Grid breakpoints. `size.lg` is the width a module gets when it is dropped (Frame tiles can't be resized). |
| `web.modules[].touchPoints` | Optional. Add `["floatingButton"]` to offer a module in the Floating Button picker. |
| `backend` | Keyed by language (`js` or `py`). Declares `database` (`postgres`, `mongodb`) and, for `js`, `kafka.required`. |

---

## Prerequisites

- Node.js 22 and npm (npm only; no yarn or pnpm)
- A local checkout of **cs-portal** (the shell) to load the module in

## Run it locally

You run three processes: the backend, the extension's web dev server, and the shell.

```sh
# 1. Backend: http://localhost:8000
cd js
npm install
npm start

# 2. Web remote: serves remoteEntry.js
cd web
npm install
APP_PORT=3001 npm start          # export APP_PORT, otherwise webpack falls back to 8080

# 3. Shell: in your cs-portal checkout (http://localhost:3000)
npm start                        # set TENANT_HOST_NAME in cs-portal/env/.env
```

Then point a grid slot in your **local** cs-portal route config at the remote and keep that change
out of your commits:

```json
{
  "url": "http://localhost:3001/remoteEntry.js",
  "scope": "remote",
  "module": "./HelloWorld",
  "size": { "lg": 12, "md": 12, "sm": 12, "xs": 12 }
}
```

Opening the web dev server directly shows nothing useful: shell services such as `getTheme()` only
exist once cs-portal has called `initializeHost()`.

---

## Make it yours

When you copy this template, change these together. They must all agree.

1. `manifest.json`: `tenant`, `extensionName`, `displayName`, `description`.
2. `web/src/utils/appConfig.ts`: the `TENANT_NAME` and `EXTENSION_NAME` fallbacks. The platform
   build does not set these variables, so the fallbacks are what ships.
3. `build.sh`: `FINAL_ZIP_NAME`, and `FOLDERS` if your backend is `py` instead of `js`.
4. `web/webpack/webpack.common.cjs`: the keys in `exposes`, kept one-to-one with
   `manifest.json` `web.modules[].module`.
5. For a Python backend: pass `type: 'py'` once inside `ExtensionManager.getExtAxios()`.

## Shell services

Everything the shell provides comes through
[`@cloudscaile-eng/web-ext-utils`](https://www.npmjs.com/package/@cloudscaile-eng/web-ext-utils),
wrapped once in `web/src/utils/extension.ts` (`extensionManager`). Keep this package at the same
version as cs-portal (currently `^0.0.8`). Note that `^0.0.x` ranges never update by themselves in
npm, so bump it deliberately.

| Capability | Functions |
|------------|-----------|
| HTTP | `getExtAxios` |
| State | `getReduxStore`, `injectReducers` |
| UI | `getTheme`, `toast` |
| i18n | `registerTranslation`, `getNsForTranslation` |
| User and roles | `getUser`, `validateUserPermission` |
| Auth | `triggerLogin`, `triggerGuestLogin`, `triggerLogout`, `getOAuthProviders`, `triggerSendOTP`, `triggerSignUp` |
| Consent and analytics | `getCookieConsent`, `updateCookieConsent`, `resetCookieConsent`, `trackGA4Event`, `trackGTMEvent` |
| Events | `getEventBus` |

### Five things the shell owns

| Never | Instead |
|-------|---------|
| `fetch()` or `axios.create()` | `extensionManager.getExtAxios()` |
| Your own Redux `<Provider>` | `extensionManager.injectReducers()` |
| `createTheme()` or hex colours | `<ThemeProvider theme={extensionManager.getTheme()}>` |
| A toast library | `extensionManager.toast()` |
| `<BrowserRouter>` or `<Routes>` | `useNavigate` / `useParams` from the shared `react-router` |

---

## Package and ship

1. **Commit.** `build.sh` archives `HEAD`, so uncommitted changes are not packaged.
2. **Package:** `./build.sh` produces `cloudscaile.starterTemplateExperience.zip`
   (`web.zip` + `js.zip` + `manifest.json`).
3. **Upload in the Designer:** **Extensions › Add Extension**, then either
   - **Upload ZIP**: select the zip, pick the backend **Language** and paste its secrets, or
   - **Repo details**: the Git repository URL, a branch or tag, and a token for private repos.
4. **Wait for the status** to move from **In Progress** to **Active** (the list refreshes every two
   minutes). If it lands **Inactive**, use the row's **…** menu › **Activate**.
5. **Optional setup** from the row's **…** menu: **Configure › Backend** for environment variables,
   and **Manage Permissions** for permission keys that you check with `validateUserPermission`.
6. **Place it on a page:** **Frame › Create Page** (title, description, route), drag **Hello World**
   from **Components › Extensions**, set its Props with the gear › **Properties**, then **Save**.
   Saving is live immediately; there is no draft or preview.

The platform's build runs `npm ci --ignore-scripts` and `npm run build` in `web/`, so keep
`package-lock.json` committed and make sure the build writes to `dist/`.

---

## Related templates

- [starter-template](https://github.com/Cloudscaile-Experience/starter-template): this repository
- [telehealth-booking-and-consultation](https://github.com/Cloudscaile-Experience/telehealth-booking-and-consultation): full-stack reference with a FastAPI backend, Postgres, Docker and Lefthook
- [patient-management-portal](https://github.com/Cloudscaile-Experience/patient-management-portal): the same web patterns with a Node backend
