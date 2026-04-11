# Project Rules

## Before Pushing

Always run linter and tests before `git push`:

```bash
bin/rubocop -a && bin/rails test
```

Only push if both pass. Fix any failures before pushing.
