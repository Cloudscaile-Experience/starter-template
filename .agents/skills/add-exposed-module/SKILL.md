---
name: add-exposed-module
description: Use this skill when adding a new module that the shell can mount (a new tile in the Designer's Frame editor). Covers the container, webpack exposes and manifest.json.
---

# Instructions

A module is something the shell can mount into a grid slot. Three places must agree.

1. **Create the container** (`src/containers/MyModuleContainer.tsx`). It default-exports a component
   wrapped in `<App>`, registers translations at module scope, and gives every prop a default:

   ```tsx
   import { Suspense } from 'react';

   import App from '@/App';
   import myModuleTranslations from '@/locales/myModule.json';
   import { extensionManager } from '@/utils/extension';

   const ns = extensionManager.getNsForTranslation('myModule');
   extensionManager.registerTranslation(ns, myModuleTranslations);

   interface MyModuleProps {
     basePath?: string;
   }

   const MyModuleContainer: React.FC<MyModuleProps> = ({ basePath = '/my-module' }) => (
     <App>
       <Suspense fallback={null}>
         <MyModule ns={ns} basePath={basePath} />
       </Suspense>
     </App>
   );

   export default MyModuleContainer;
   ```

2. **Expose it** in `web/webpack/webpack.common.cjs`:

   ```js
   exposes: {
     './HelloWorld': './src/components/HelloWorld',
     './MyModule': './src/containers/MyModuleContainer'
   }
   ```

3. **List it** in `manifest.json` under `web.modules`:

   ```json
   {
     "name": "My Module",
     "description": "What a page builder needs to know about this module",
     "module": "./MyModule",
     "size": { "lg": 12, "md": 12, "sm": 12, "xs": 12 }
   }
   ```

   `size.lg` is the width the tile gets when dropped in Frame (tiles cannot be resized there). Add
   `"touchPoints": ["floatingButton"]` if the module should be offered in the Floating Button picker.

**Checks:**

- The `exposes` key and the manifest `module` are identical strings, including the `./`.
- The component has a default export.
- The shell only passes the Props JSON set in the Designer, so the module works with no props.
- Run `npm run check` and `npm run type-check`.
