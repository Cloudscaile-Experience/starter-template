---
name: package-and-deploy
description: Use this skill when packaging the extension with build.sh and taking it live through the Designer (Extensions upload, backend env, permissions, Frame page placement).
---

# Instructions

## 1. Before packaging

- `manifest.json` `tenant` and `extensionName` match the fallbacks in `web/src/utils/appConfig.ts`
  and `FINAL_ZIP_NAME` in `build.sh`. The platform build does not set `TENANT_NAME` /
  `EXTENSION_NAME`, so the fallbacks are what ships.
- Every `exposes` key is listed in `manifest.json` `web.modules`.
- `@cloudscaile-eng/web-ext-utils` matches the version cs-portal uses.
- No `getExtAxios({ local: true })` in source.
- `npm run check`, `npm run type-check` and `npm run build` pass in `web/`.
- `web/package-lock.json` is committed. The platform runs `npm ci --ignore-scripts` and
  `npm run build`, and publishes `dist/`.

## 2. Package

```sh
git commit ...        # build.sh uses `git archive HEAD`: uncommitted changes are NOT packaged
./build.sh            # → cloudscaile.<extensionName>.zip (web.zip + js.zip + manifest.json)
```

## 3. Upload in the Designer

1. Sidebar **Extensions** › **Add Extension** (needs the `extension.update` permission).
2. Either:
   - **Upload ZIP**: **Select .zip File**, choose the backend **Language** (JS/PY) and fill
     "Secrets for …", then **Submit**; or
   - **Repo details**: Git repository URL, **Branch** or **Tag**, and a repository token for
     private repos.
3. The row shows **In Progress**, then **Active** or **Inactive** (the list refreshes every two
   minutes). If Inactive: row **…** › **Activate**.
4. New version later: row **…** › **Update** (same dialog).

## 4. Optional setup

- Row **…** › **Configure** › **Backend**: environment variables (UPPER_SNAKE keys; values are
  write-only once saved).
- Row **…** › **Manage Permissions** › **Create Permission**: permission keys such as
  `item.create` (cannot be renamed later). Map them to roles under **User roles**; check them in code
  with `validateUserPermission`.

## 5. Place it on a page

1. Sidebar **Frame** › **Create Page**: Title, Description, Route (no leading slash; cannot start
   with `cs-portal` or `cs-designer`).
2. From **Components** › **Extensions**, drag a module onto the canvas. Dropping it onto another
   module creates an Extension container with child routes.
3. Tile gear › **Properties**: set **Props** (a non-empty JSON object) and optional SX/Tailwind.
4. Pencil › page settings: Route, Role, **Login required**, **Default public** / **Default private**.
5. **Save**. It is live for the tenant immediately; there is no draft or preview.
