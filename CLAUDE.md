# Project Rules

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
