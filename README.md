# Starter Template — Cloudscaile Extension

The smallest complete Cloudscaile extension: a **web** front end and a **js** backend, packaged
together and installed on a tenant through the **Designer**. Copy this repository to start a new
extension, rename its identity, and ship it end to end before adding features.

---

## Repository layout

```
starter-template/
├── manifest.json     # Extension identity, modules and backend needs
├── build.sh          # Packages the last commit into cloudscaile.<extensionName>.zip
├── web/              # Front end (see web/README.md)
└── js/               # Node backend
```

Each half is a separate npm project with its own `package.json`. See `web/README.md` for the front
end's setup, scripts and conventions.

## Prerequisites

- Node.js 22 and npm (npm only; no yarn or pnpm)
- A local checkout of **cs-portal** to try the extension the way users will see it

---

## Make it yours

When you copy this template, update the identity in one go so everything agrees:

1. `manifest.json`: `tenant`, `extensionName`, `displayName`, `description`.
2. `web/src/utils/appConfig.ts`: the `TENANT_NAME` and `EXTENSION_NAME` fallbacks.
3. `build.sh`: `FINAL_ZIP_NAME`, and `FOLDERS` if you add or rename a backend folder.

---

## Package and ship

1. **Commit.** `build.sh` archives `HEAD`, so uncommitted changes are not packaged.
2. **Package:** run `./build.sh`. It zips each folder in `FOLDERS` and wraps them with
   `manifest.json` into `cloudscaile.starterTemplateExperience.zip`.
3. **Upload in the Designer:** **Extensions › Add Extension**, then either
   - **Upload ZIP**: select the zip, pick the backend **Language** and paste its secrets, or
   - **Repo details**: the Git repository URL, a branch or tag, and a token for private repos.
4. **Wait for the status** to move from **In Progress** to **Active** (the list refreshes every two
   minutes). If it lands **Inactive**, use the row's **…** menu › **Activate**.
5. **Optional setup** from the row's **…** menu: **Configure › Backend** for environment variables,
   and **Manage Permissions** for permission keys.
6. **Place it on a page:** **Frame › Create Page** (title, description, route), drag a module from
   **Components › Extensions**, set its Props with the gear › **Properties**, then **Save**.
   Saving is live immediately; there is no draft or preview.

To ship a new version later, commit, run `./build.sh` again and use the row's **…** › **Update**.

---

## Related templates

- [starter-template](https://github.com/Cloudscaile-Experience/starter-template): this repository
- [telehealth-booking-and-consultation](https://github.com/Cloudscaile-Experience/telehealth-booking-and-consultation): full-stack reference with a FastAPI backend, Postgres, Docker and Lefthook
- [patient-management-portal](https://github.com/Cloudscaile-Experience/patient-management-portal): the same web patterns with a Node backend
