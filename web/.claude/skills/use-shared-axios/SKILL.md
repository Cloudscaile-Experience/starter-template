---
name: use-shared-axios
description: Use this skill to make API calls with the shell's shared axios instance (extensionManager.getExtAxios) and to choose the right base URL option.
---

# Instructions

All HTTP goes through the shell's axios factory. It builds the gateway URL for this extension,
adds the user's Bearer token, and signs the user out on a 401.

1. **Import the Extension Manager:**

   ```typescript
   import { extensionManager } from '@/utils/extension';
   ```

2. **Create an API class** per resource. Get the instance lazily so it is created after the shell
   has initialised:

   ```typescript
   class ItemsApi {
     private get axios() {
       return extensionManager.getExtAxios();
     }

     async list(): Promise<Item[]> {
       const { data } = await this.axios.get<Item[]>('/v1/items');
       return data;
     }
   }

   export const itemsApi = new ItemsApi();
   ```

   Paths are relative to your backend root: `/v1/items` becomes
   `{APP_BASE_URL}/v1/extensions/access/{tenant}/{extensionName}/{type}/v1/items`.

3. **Choose the right option:**

   | Option | Base URL | Use it for |
   |--------|----------|------------|
   | (none) | `/v1/extensions/access/{tenant}/{name}/{type}` | Signed-in calls to your backend |
   | `open: true` | `/v1/extensions/public/{tenant}/{name}/{type}` | Public endpoints (see `src/api/openApi.ts`) |
   | `host: true` | `APP_BASE_URL` | Platform APIs |
   | `type: 'py'` | | Python backend; set it once in `ExtensionManager.getExtAxios()` |
   | `errorToast: true` | | The shell shows the API's error message as a toast |
   | `local: true` | `APP_LOCAL_API_URL` | Local debugging only — **never commit it** |

4. **Consume it through TanStack Query** hooks in `src/hooks/` (see `useHelloWorld.ts`).

**Error handling:** the shared instance already handles 401s and can show error toasts. Only catch
errors when the component needs specific fallback behaviour.
