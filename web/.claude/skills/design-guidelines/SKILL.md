---
name: design-guidelines
description: Design guidelines for Material-UI (MUI). Focuses on using the tenant's host theme tokens instead of fixed colours, rounded layout, and component usage via the `sx` prop.
---

# Design & Styling Rules (MUI)

## Overview

This application uses a clean, modern, and light UI aesthetic governed by a predefined MUI theme. All styling must adhere strictly to the tokens defined in the host application's theme object.

**CRITICAL RULE:** Do NOT hardcode hex colors or arbitrary pixel values if a theme token exists. The host application provides the theme via `extensionManager.getTheme()`. You MUST rely on the MUI components' default styles as they have been heavily customized in the global theme.

Each tenant configures its own theme in the Designer (Style builder), so the colour names below describe the default theme only. Always reference the token (`primary.main`), never the colour you expect it to be.

## 1. MUI Theme Tokens

- **Colors**:
  - Primary Action: `primary.main` (Blue)
  - Secondary Action: `secondary.main` (Orange)
  - Backgrounds: `background.default` (slate 50), `background.paper` (white)
  - Text: `text.primary` (dark slate), `text.secondary` (slate 500)
  - Status/Feedback: `success.main` (emerald), `error.main` (red), `warning.main` (amber), `info.main` (blue)
- **Typography**:
  - `fontFamily`: 'IBM Plex Sans', sans-serif
  - Use the standard MUI `<Typography>` component. The fonts and weights are already globally mapped.
- **Border Radius (Shape)**:
  - The design language heavily features soft, rounded corners:
    - **Buttons & Inputs**: `10px`
    - **Cards & Dialogs**: `16px`
    - **Chips, Tooltips, MenuItems**: `8px`
    - **Paper**: `12px`
  - Do NOT override these border radii manually; simply use the correct MUI component, and the theme overrides will apply them automatically.

## 2. Component Usage

The host application's theme has deep structural overrides for MUI components. Use standard components out of the box to inherit these styles:

### Buttons

Use `<Button variant="contained">` or `<Button variant="outlined">`.

- The theme automatically applies a `10px` border radius, `textTransform: "none"`, and a custom hover elevation effect (`translateY(-1px)`).
- Do not manually construct buttons out of `Box` elements.

### Cards & Surfaces

Use `<Card>` and `<Paper>`.

- `<Card>` automatically receives a `16px` border radius, custom soft shadows, and a hover translation effect (`translateY(-4px)`). Use `<CardContent>` for consistent `24px` padding.
- `<Paper>` has custom shadow elevations (elevation 1, 2, 3) and a `12px` border radius when rounded.

### Inputs & Forms

Use `<TextField>`.

- The theme automatically sets a `10px` border radius on the outlined input, along with custom primary-colored borders and box-shadows on hover and focus.

### Navigation & Layout

- Use `<Tabs>` and `<Tab>`. The theme sets a `3px` thick indicator with rounded top corners.
- Use `<Accordion>` for collapsable sections, which the theme styles with a `12px` border radius and no standard lines (`&:before: display: none`).

## 3. Styling Strategy & Layouts

- **Use the `sx` prop**: For any layout, margin, padding, or flexbox needs, use the `sx` prop directly on MUI components.
- **Layout Primitives**:
  - `<Stack>`: For 1-dimensional layouts (rows/columns) with consistent spacing.
  - `<Box>`: For general containers.
  - `<Grid>`: For 2-dimensional layouts.
- **Avoid Custom CSS**: Do not create raw `.css`, `.scss`, or `.module.css` files. All styling should remain in TypeScript via the `sx` prop or `@mui/material/styles` `styled()` API.

## 4. Do / Do Not

- **Do**: Use standard MUI components (Card, Button, TextField) to inherit the host's heavy customizations.
- **Do**: Use theme color paths in `sx` (`color: 'primary.main'`, `bgcolor: 'background.paper'`).
- **Never**: Hardcode hex colors like `#0250D9` or `#FF6B35` in your components. The theme might change; always use `primary.main` or `secondary.main`.
- **Never**: Apply manual `borderRadius` or `boxShadow` values via `sx` unless you are creating a completely custom element that has no MUI equivalent.
- **Never**: Attempt to recreate hover effects (like card lift or button shadows) that are already handled globally by the host theme.
