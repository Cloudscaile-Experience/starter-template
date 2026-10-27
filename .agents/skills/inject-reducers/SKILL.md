---
name: inject-reducers
description: Use this skill to learn how to add Redux state slices to the host application's global Redux store.
---

# Instructions

To manage global state, you use Redux Toolkit slices, but instead of creating a store, you inject your reducers into the host.

1. **Create your Redux Slice:**
   Use `@reduxjs/toolkit` as usual.

   ```typescript
   // src/slice/myFeatureSlice.ts
   import { createSlice } from '@reduxjs/toolkit';

   const myFeatureSlice = createSlice({
     name: 'myFeature',
     initialState: { data: [] },
     reducers: {
       setData: (state, action) => {
         state.data = action.payload;
       }
     }
   });

   export const { setData } = myFeatureSlice.actions;
   export default myFeatureSlice.reducer;
   ```

2. **Inject the Reducer at Startup:**
   Inject the reducer at module scope in the exposed container (before it renders), using `extensionManager`.
   The shell throws if a key already exists in the store, unless you list that key in the second
   argument (`replace`). Keys in the third argument (`whitelist`) are persisted by redux-persist.
   Prefix keys with your extension name to avoid collisions with other extensions.

   ```typescript
   import { extensionManager } from '@/utils/extension';
   import myFeatureReducer from '@/slice/myFeatureSlice';

   // Inject the reducer and add it to the whitelist if you want it persisted
   extensionManager.injectReducers(
     { myFeature: myFeatureReducer }, // The reducers to inject
     [], // Reducers to replace (usually empty)
     ['myFeature'] // Whitelist for persistence
   );
   ```

3. **Use the State in Components:**
   Use standard Redux hooks (`useSelector`, `useDispatch`) in your components. They will automatically connect to the host's store.

   ```typescript
   import { useSelector, useDispatch } from 'react-redux';

   const data = useSelector((state: any) => state.myFeature.data);
   ```
