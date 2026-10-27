---
name: mui-usage
description: Use this skill whenever building or styling UI components with Material-UI (MUI). Enforces the use of the `sx` prop, custom styled components, and strict adherence to the micro-frontend theming rules.
---

# Material-UI (MUI) Skill

This project uses Material-UI (MUI) for its component library and styling.

## Core Patterns

### Micro-Frontend Theming Constraint

**CRITICAL:** Do NOT use `createTheme()` or attempt to define a local theme context. This application is a micro-frontend, and it must seamlessly blend with the host application.

The host application's theme is automatically provided to the root `<ThemeProvider>` via `extensionManager.getTheme()`. You can trust that the standard MUI theme tokens (colors, typography, spacing) are pre-configured.

### Styling Strategy

You have two primary ways to style components in MUI:

1. **The `sx` prop (Utility-First):**
   Use the `sx` prop for rapid UI development and most single-use styling directly on MUI components. It has access to the theme natively.

   ```tsx
   <Box sx={{ p: 2, display: 'flex', bgcolor: 'primary.main', borderRadius: 1 }}>Content</Box>
   ```

2. **`styled()` API (Component-First):**
   Use the `styled()` utility from `@mui/material/styles` for highly customized, reusable components or when the `sx` prop becomes too long and clutters the JSX.

   ```tsx
   import { styled } from '@mui/material/styles';
   import Button from '@mui/material/Button';

   const CustomButton = styled(Button)(({ theme }) => ({
     padding: theme.spacing(2),
     backgroundColor: theme.palette.secondary.main,
     '&:hover': {
       backgroundColor: theme.palette.secondary.dark
     }
   }));
   ```

### Layout Components

Always prefer MUI's layout components over raw HTML/CSS flexbox and grid definitions:

- **`Stack`**: For 1-dimensional layouts (rows or columns) with consistent spacing.
  ```tsx
  <Stack direction="row" spacing={2} alignItems="center">...
  ```
- **`Box`**: As a generic container (like a `div`) that supports the `sx` prop.
- **`Grid`**: For 2-dimensional layouts.

## Typography

Always use the `<Typography>` component rather than raw `<p>`, `<h1>`, or `<span>` tags. The variant maps to the theme's typography definitions.

```tsx
<Typography variant="h6" color="text.secondary">
  Subtitle
</Typography>
```

## Icons

Use icons from `@mui/icons-material`.

```tsx
import SearchIcon from '@mui/icons-material/Search';

<SearchIcon color="action" />;
```

## Avoid CSS Files

Do not create raw `.css`, `.scss`, or `.module.css` files unless strictly necessary for integrating a third-party non-React library. All styling should remain in TypeScript via `sx` or `styled()`.
