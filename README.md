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

Deployed to a Hetzner VPS via [Kamal](https://kamal-deploy.org). See
`config/deploy.yml` for the topology and `script/hetzner-bootstrap.sh` for the
one-shot server prep.

### Infrastructure

- **App**: Rails 8 + Thruster + Puma in a Docker image on GHCR.
- **Proxy**: `kamal-proxy` for zero-downtime deploys, behind `caddy:2-alpine`.
- **TLS**: Caddy terminates TLS with Let's Encrypt.
  - `slsh.me` + `app.slsh.me` get certs on `kamal setup`.
  - Customer custom domains get on-demand certs — first HTTPS request after
    DNS resolves triggers issuance, gated by the `/domain_check` endpoint so
    random Host headers can't burn our ACME rate limit.
- **Database**: Postgres 17 (Kamal accessory on the same host, bound to
  `127.0.0.1`).

### Custom domains

Customers run their domain through slsh.me by:

1. Adding the domain on `/settings/domains`.
2. Creating a CNAME record: `their-domain.com → slsh.me`.
3. Opening `https://their-domain.com/<slug>` — Caddy fetches an LE cert on
   the first request and serves the redirect.

### Manual deploy

```sh
bin/kamal deploy
```
