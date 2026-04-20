# n8n-heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/n8n-io/n8n-heroku/tree/main)

## n8n - Free and open fair-code licensed node based Workflow Automation Tool.

This is a [Heroku](https://heroku.com/)-focused container implementation of [n8n](https://n8n.io/).

Use the **Deploy to Heroku** button above to launch n8n on Heroku. When deploying, make sure to check all configuration options and adjust them to your needs. It's especially important to set `N8N_ENCRYPTION_KEY` to a random secure value.

Refer to the [Heroku n8n tutorial](https://docs.n8n.io/hosting/server-setups/heroku/) for more information.

If you have questions after trying the tutorials, check out the [forums](https://community.n8n.io/).

---

## Deploying to multiple Heroku apps

### Prerequisites

- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed and logged in (`heroku login`)
- Git remote access to each target app (you must be a collaborator or owner)

### 1. Register your apps

Add each Heroku app name (one per line) to `heroku-apps.txt`:

```
dansys25
dansys25-erfurt
dansys25-flensburg
...
```


### 2. Run the deploy script

**Check what's currently deployed across all apps:**
```bash
./deploy.sh status
```
```
APP                                 N8N VERSION     DEPLOYED AT          BRANCH
---                                 -----------     -----------          ------
my-n8n-production                   2.17.3          2026-04-20 14:32     main
my-n8n-staging                      (never deployed)
```

**Deploy to one or more apps:**
```bash
./deploy.sh my-n8n-production
./deploy.sh my-n8n-production my-n8n-staging
```

The script:
1. Validates every name against `heroku-apps.txt` — unknown apps abort before anything is pushed
2. Pushes the **current branch** to each target app
3. Creates/updates a git tag `deployed/<app-name>` on origin recording the n8n version, branch, and timestamp

### Notes

- Heroku builds the container on their side via `heroku.yml` — no local Docker needed.
- Be on the correct branch (`main` for pinned stable, `latest` for tracking upstream) before deploying.
- Monitor a deploy with `heroku logs --tail --app <app-name>`.
