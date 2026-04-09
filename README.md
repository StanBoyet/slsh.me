# slsh.me

URL shortener and link analytics service.

## Development

### Requirements

- Ruby (see `.ruby-version`)
- PostgreSQL

### Setup

```sh
bin/setup
bin/dev
```

### Tests

```sh
bin/rails test
bin/rails test:system
```

## Deployment

The app is deployed to [Fly.io](https://fly.io). Deploys happen automatically on push to `master` after CI passes.

### Infrastructure

- **App**: `slsh-me` (region: `cdg`)
- **Database**: `slsh-me-db` (Fly Postgres, shared-cpu-1x, 1GB volume)

### Secrets

The following secrets must be set on the Fly app:

```sh
flyctl secrets set RAILS_MASTER_KEY=<value from config/master.key> --app slsh-me
```

For CI/CD, add `FLY_API_TOKEN` to GitHub repo secrets:

```sh
flyctl tokens create deploy -a slsh-me
# Then add the token at Settings > Secrets and variables > Actions > FLY_API_TOKEN
```

### Manual deploy

```sh
flyctl deploy --remote-only
```
