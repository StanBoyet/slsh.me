# Project Rules

## Design System

The visual language is **Splash × Beam** — a sticker-style baseline (ink borders, marker highlights, hard-shadow card pops) with surgical Beam injections (gradient corner orbs on KPI tiles + feature cards). The full spec lives at:

- **`public/brand/design-system.html`** — foundations (color palette + gradients, typography rules, shape) + every component (buttons, badges, stickers, chips, stat tiles, feature cards, icon buttons, sparklines, markers, code chips, link row pattern, final CTA, empty state) + in-situ links to the chosen surfaces.
- **`public/brand/final.html`** — links-index app screen rendered in the chosen direction.
- **`public/brand/landing-final.html`** — full marketing landing page in the chosen direction.
- **`public/brand/exploration/`** — earlier shelved directions (Splash, Beam, Signal, Highlighter, Prism, Spark) kept for reference.

Tokens, component classes, and base typography rules are implemented in `app/assets/tailwind/application.css`. Reuse the existing component classes (`.btn-tangerine`, `.sticker.s-*`, `.stat-tile.t-*`, `.feat-card.fc-*`, `.icon-btn`, `.marker.m-*`, `.brand-mark`, `.empty-mark`, `.camp-banner`, `.link-card`, `.hero-mini`, `.flash-card`, `.dropdown-panel`, `code.method`, etc.) instead of inline styles.

**Typography rule**: Migra carries only the page hero `h1.hero` (or `.hero-mini` on auth pages). Every other H2 / H3 / heading uses General Sans. Mono (JetBrains Mono) for slugs and code chips.

## Before Pushing

Always run linter and tests before `git push`:

```bash
bin/rubocop -a && bin/rails test
```

Only push if both pass. Fix any failures before pushing.

## Target Audience

slsh.me is a free link shortener competing with Bitly. The product is simple, so the landing page must overcome "yet another tool" inertia by making visitors immediately self-identify.

Three personas, each with second-person narrative copy and a workflow-specific mockup:

1. **Marketers** — multi-channel campaigns, UTM attribution, Friday reporting
2. **Developers** — API-driven short links, branded domains via CNAME
3. **Creators** — custom OG previews, branded social cards

The goal: visitors see themselves and think "ah, that's how I'd use this in my day-to-day."
