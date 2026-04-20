# n8n-heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/n8n-io/n8n-heroku/tree/main)

## n8n - Free and open fair-code licensed node based Workflow Automation Tool.

This is a [Heroku](https://heroku.com/)-focused container implementation of [n8n](https://n8n.io/).

Use the **Deploy to Heroku** button above to launch n8n on Heroku. When deploying, make sure to check all configuration options and adjust them to your needs. It's especially important to set `N8N_ENCRYPTION_KEY` to a random secure value.

Refer to the [Heroku n8n tutorial](https://docs.n8n.io/hosting/server-setups/heroku/) for more information.

If you have questions after trying the tutorials, check out the [forums](https://community.n8n.io/).

---

## Branches

| Branch | n8n image | Use when |
|--------|-----------|----------|
| `main` | `n8nio/n8n:2.16.1` (pinned) | Production — stable, explicit version |
| `latest` | `n8nio/n8n:latest` | Tracking upstream automatically |

---

## Deploying to multiple Heroku apps

### Prerequisites

- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed and logged in (`heroku login`)
- Git remote access to each target app (you must be a collaborator or owner)

### 1. Register your apps

Add each Heroku app name (one per line) to `heroku-apps.txt`:

```
my-n8n-production
my-n8n-staging
```

Lines starting with `#` are treated as comments and ignored.

### 2. Run the deploy script

```bash
./deploy.sh <app-name> [app-name ...]
```

The script:
1. Validates every name you pass against `heroku-apps.txt` — typos or unknown apps abort before anything is pushed
2. Pushes the **current branch** to each target app's `main` branch

**Examples**

Deploy to a single app:
```bash
./deploy.sh my-n8n-production
```

Deploy to multiple apps at once:
```bash
./deploy.sh my-n8n-production my-n8n-staging
```

List all registered apps (run with no arguments):
```bash
./deploy.sh
```

### Notes

- Heroku builds the container on their side using `heroku.yml`, so no local Docker is required.
- Make sure you are on the correct branch (`main` for pinned, `latest` for tracking upstream) before running the script.
- Each push triggers a fresh build and release on Heroku. You can monitor progress in the Heroku dashboard or via `heroku logs --tail --app <app-name>`.
