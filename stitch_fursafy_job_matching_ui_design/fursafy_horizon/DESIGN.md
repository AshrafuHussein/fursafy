# Design System Documentation

## 1. Overview & Creative North Star: "The Digital Curator"

This design system moves beyond the utility of a standard job board to create a high-end, editorial experience for Tanzanian youth. Our Creative North Star is **The Digital Curator**. Instead of a cluttered grid of listings, the UI should feel like a curated gallery of opportunities—sophisticated, intentional, and deeply professional.

To achieve this, we break the "template" look through:
*   **Intentional Asymmetry:** Overlapping elements and varied card widths to guide the eye.
*   **Tonal Depth:** Replacing harsh lines with sophisticated background shifts.
*   **Editorial Scale:** High-contrast typography that makes a statement.

The system balances the "Growth" of our `primary` green with the "Vitality" of our `secondary` amber, set against a warm, "Paper-like" neutral palette that feels grounded and premium.

---

## 2. Colors

Our color strategy is rooted in Material Design 3 logic but applied with an editorial eye. We use color to define space, not just decoration.

### The Palette
*   **Primary (`#00694c`):** Used for core brand moments and primary actions. It represents the professional "Growth" engine.
*   **Secondary (`#855400` / Amber accents):** Represents youth energy. Use sparingly for high-interest highlights and "new" indicators.
*   **Surface Tiers:** We use a warm gray foundation (`#faf9f4`) to create a welcoming, organic feel.

### Critical Color Rules
*   **The "No-Line" Rule:** 1px solid borders are strictly prohibited for sectioning. Boundaries must be defined solely through background shifts. For example, a `surface-container-low` section sitting on a `surface` background.
*   **Surface Hierarchy & Nesting:** Treat the UI as stacked sheets of fine paper. 
    *   *Example:* An activity feed (on `surface-container-low`) containing individual job cards (on `surface-container-lowest`).
*   **The "Glass & Gradient" Rule:** For floating elements (like Bottom Navigation or FABs), use Glassmorphism. Apply semi-transparent surface colors with a `backdrop-filter: blur(20px)`.
*   **Signature Textures:** For Hero sections or primary CTAs, use a subtle linear gradient from `primary` (#00694c) to `primary_container` (#008560) to add "soul" and depth.

---

## 3. Typography

We pair two distinct sans-serifs to create an editorial rhythm: **Plus Jakarta Sans** for character and **Manrope** for clarity.

### The Scale
*   **Display & Headline (Plus Jakarta Sans):** These are your "Editorial" voices. Use `display-lg` for welcome screens and `headline-md` for section headers. The slightly wider stance of Jakarta Sans conveys authority.
*   **Title & Body (Manrope):** These are your "Functional" voices. Manrope's high x-height ensures readability on small mobile screens.
*   **Labels (Manrope):** Use `label-md` for metadata (e.g., job location, date posted).

**Typography Hierarchy:**
Always lead with a strong headline. Don't be afraid of whitespace. Let the `headline-lg` breathe with significant top and bottom margins to signify a change in content "chapter."

---

## 4. Elevation & Depth

We avoid the "pasted-on" look of traditional shadows. Depth in this system is organic and atmospheric.

### The Layering Principle
Hierarchy is achieved by "stacking" surface tiers.
*   **Base:** `surface` (Background)
*   **Sectioning:** `surface-container-low`
*   **Interactive Cards:** `surface-container-lowest` (the "whitest" white, creating a natural lift).

### Ambient Shadows
When a floating effect is required (e.g., a "Quick Apply" modal):
*   **Blur:** Large (24px–40px).
*   **Opacity:** Ultra-low (4%–8%).
*   **Color:** Tint the shadow with the `on-surface` color. Never use pure black shadows; they look "dirty."

### The "Ghost Border" Fallback
If an element lacks contrast (e.g., on a specific screen brightness), use a "Ghost Border": the `outline-variant` token at **15% opacity**. It provides a hint of structure without breaking the seamless tonal flow.

---

## 5. Components

### Cards & Lists
*   **Rule:** Forbid the use of divider lines.
*   **Execution:** Use `md` (0.75rem) or `lg` (1rem) corner radius. Separate list items using vertical white space from the spacing scale. Use a `surface-container-high` background on hover/press states instead of a border.

### Buttons
*   **Primary:** Filled with `primary`, text in `on-primary`. Roundedness: `full`.
*   **Secondary:** Filled with `secondary_container`, text in `on-secondary_container`. Use for high-energy youth-focused actions.
*   **Tertiary:** No background. Use `primary` text. Reserved for low-emphasis actions like "Cancel" or "Skip."

### Input Fields
*   **Style:** Use the "Filled" Material style but with a twist. The background should be `surface-container-highest` with a `none` border. 
*   **Interaction:** Upon focus, the background shifts to `surface-container-low` with a 2px `primary` bottom-indicator only.

### Chips
*   **Selection:** Use `primary_fixed` for selected states to provide a soft, high-end highlight that isn't as aggressive as the full `primary` color.

### Contextual Components for the Platform
*   **The "Growth Progress" Bar:** Use a gradient of `primary` to show profile completion.
*   **Job Category Badges:** Use `secondary_fixed_dim` (Amber) for trending job categories to make them "pop" against the green brand colors.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical margins (e.g., 24px left, 16px right) on certain decorative headers to create an editorial feel.
*   **Do** prioritize large touch targets (minimum 48x48dp) for mobile-first accessibility.
*   **Do** use `surface-bright` for the most important "Read Me" content.

### Don't
*   **Don't** use 100% opaque black for text. Always use `on-surface` or `on-surface-variant` for a softer, more professional look.
*   **Don't** use standard "Drop Shadows." If it looks like a default Flutter/Android shadow, it's too heavy.
*   **Don't** use dividers to separate content. If the content feels cluttered, increase the spacing or shift the background tone.

---

## 7. Roundedness Scale Reference
Use these tokens consistently to maintain the "Soft Professionalism" of the system:
*   **`sm` (0.25rem):** Minor utility elements (Checkboxes).
*   **`DEFAULT` (0.5rem):** Standard inputs.
*   **`md` (0.75rem):** Smaller job cards.
*   **`lg` (1rem):** Feature cards, Modals.
*   **`xl` (1.5rem):** Bottom sheets, Hero containers.
*   **`full`:** Buttons, Chips, Search bars.