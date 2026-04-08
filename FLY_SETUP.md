# Fly.io Deployment Setup

## Prerequisites

```bash
brew install flyctl
fly auth login
```

## Initial Setup

```bash
# 1. Create the app (don't deploy yet)
fly launch --no-deploy --name slsh-me

# 2. Create managed PostgreSQL cluster
fly postgres create --name slsh-me-db --region cdg

# 3. Attach PG to app (sets DATABASE_URL secret automatically)
fly postgres attach slsh-me-db --app slsh-me

# 4. Set required secrets
fly secrets set \
  RAILS_MASTER_KEY=$(cat config/master.key) \
  APP_HOST=slsh.me \
  IPINFO_TOKEN=<your_ipinfo.io_token>

# 5. Deploy
fly deploy
```

## Worker Process

The `worker` process (Solid Queue) is defined in `fly.toml` under `[processes]`.
Fly.io automatically runs it alongside the `app` process.

To scale them independently:
```bash
fly scale count app=1 worker=1
```

## Useful Commands

```bash
fly logs                          # tail production logs
fly ssh console                   # open a shell
fly ssh console -C "bin/rails console"  # Rails console
fly ssh console -C "bin/rails db:migrate"  # run migrations manually
fly postgres connect --app slsh-me-db  # direct PG connection
```

## Environment Variables

| Key               | Description                          |
|-------------------|--------------------------------------|
| DATABASE_URL      | Set automatically by fly pg attach   |
| RAILS_MASTER_KEY  | From config/master.key               |
| APP_HOST          | Your domain (e.g. slsh.me)           |
| IPINFO_TOKEN      | ipinfo.io API token (free: 50k/mo)   |

## Getting an ipinfo.io Token

1. Sign up at https://ipinfo.io
2. Free tier: 50,000 requests/month
3. Copy your token from the dashboard
