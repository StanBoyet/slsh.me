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
2. Creating a CNAME record: `their-domain.com → redirect.slsh.me`.
3. Opening `https://their-domain.com/<slug>` — Caddy fetches an LE cert on
   the first request and serves the redirect.

`redirect.slsh.me` is a DNS-only A record in Cloudflare pointing directly at
the origin (`91.98.29.147`). Customers **cannot** CNAME to `slsh.me`
itself because that record is proxied by Cloudflare — CF intercepts the
request, serves its own cert which doesn't match the customer's hostname,
and redirects back to the customer's domain in a loop.

### Deploys

Every push to `master` auto-deploys via `.github/workflows/ci.yml`'s
`deploy` job (after lint / test / system-test / security scans pass).
Build layers are cached to `ghcr.io/stanboyet/slsh-me:build-cache` so
code-only changes ship in ~2 min.

Manual deploy from the laptop:

```sh
bin/kamal deploy
```

**Caddyfile edits are a special case.** `bin/kamal deploy` only rolls
the app container; it does not re-sync accessory `files:`. If you
change `config/Caddyfile`, run:

```sh
bin/kamal accessory reboot caddy
```

## Observability

### Analytics & error tracking

PostHog (`posthog-ruby` + `posthog-rails`) captures user events and
unhandled exceptions. Controllers emit `user_signed_up`, `user_logged_in`,
`link_created`, `link_clicked`, `custom_domain_added`, etc. The frontend
snippet in `app/views/layouts/application.html.erb` calls
`posthog.identify` for authenticated users so client and server events
share the same `distinct_id`.

Driven by `POSTHOG_API_KEY` + `POSTHOG_HOST` — both come from GitHub
repo secrets in CI, and the initializer no-ops when the key is absent
(so test and local dev are unaffected). See
`config/initializers/posthog.rb`.

### Server metrics

Netdata runs on the server, bound to `127.0.0.1:19999` (not exposed to
the internet). To view the dashboard, open an SSH tunnel:

```sh
bin/metrics
```

Then browse `http://localhost:19999`. Charts cover the host, all
Kamal-managed Docker containers, and the Postgres accessory.
