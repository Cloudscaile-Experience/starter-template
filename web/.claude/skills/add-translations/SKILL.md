---
name: add-translations
description: Use this skill to add and register translations in the micro-frontend with @cloudscaile-eng/web-ext-utils (via extensionManager) and react-i18next.
---

# Instructions

Translations are registered into the shell's single i18n instance, under a namespace that is
unique to this extension.

1. **Create the translation file** in `src/locales/`, keyed by language at the top level:

   ```json
   // src/locales/myComponent.json
   {
     "en": {
       "title": "My component",
       "empty": "Nothing here yet"
     }
   }
   ```

2. **Register it at module scope**, in the exposed container or another module that is imported
   before anything renders:

   ```typescript
   import myComponentTranslations from '@/locales/myComponent.json';
   import { extensionManager } from '@/utils/extension';

   // Becomes `${tenant}_${extensionName}_myComponent`
   export const ns = extensionManager.getNsForTranslation('myComponent');
   extensionManager.registerTranslation(ns, myComponentTranslations);
   ```

3. **Pass the namespace down** to the components that need it, through props or a React Context.

4. **Use it** with `useTranslation(ns)`:

   ```typescript
   import { useTranslation } from 'react-i18next';

   const MyComponent: React.FC<{ ns: string }> = ({ ns }) => {
     const { t } = useTranslation(ns);
     return <Typography>{t('title')}</Typography>;
   };
   ```

**Important notes:**

- Always use the namespace from `getNsForTranslation`; a raw name like `'auth'` can collide with
  another extension or the shell.
- Never hard-code user-facing strings; add a key to `src/locales/*.json` instead.
- The shell switches language for you; do not call `i18n.changeLanguage` from the extension.
