# Hytale yolk + egg (self-hosted)

Drop-in replacement for `ghcr.io/pterodactyl/games:hytale` and `pterodactyl/game-eggs/hytale` while
[pterodactyl/yolks#71](https://github.com/pterodactyl/yolks/pull/71) and
[pterodactyl/game-eggs#477](https://github.com/pterodactyl/game-eggs/pull/477) are unmerged.

Source: `Xytronix/yolks@hytale` (`games/hytale`, commit `5d910a0`, 2026-10-24) plus a Source Query plugin
installer so the existing `INSTALL_SOURCEQUERY_PLUGIN` / `QUERY_PORT` options keep working.

## Why the old egg always updates

The upstream entrypoint runs `hytale-downloader` on every boot and has no switch for it. The
`--skip-update` flag in the egg only disables the server JAR's own in-game updater, so it never
stopped the entrypoint. This launcher only updates when `AUTO_UPDATE=1` (default `0` in this egg)
or when `SERVER_VERSION` is changed.

## Publish the image (GHCR, free for public images)

```bash
gh repo create hytale-yolk --public --source . --push   # or create the repo in the UI and push
```

The workflow in `.github/workflows/build.yml` builds `linux/amd64` + `linux/arm64` on every push to
`main`, weekly, and on manual dispatch, and pushes:

- `ghcr.io/<your-user>/hytale-yolk:latest`
- `ghcr.io/<your-user>/hytale-yolk:sha-<short>`

After the first run: GitHub > your profile > Packages > `hytale-yolk` > Package settings >
Change visibility > Public (otherwise Wings needs registry credentials to pull).

## Import the egg

1. Replace `YOUR_GITHUB_USER` in `egg-hytale.json` (`docker_images`).
2. Admin > Nests > select the nest > Import Egg. To keep existing servers, open the existing Hytale
   egg and use "Update Egg" with this file instead of importing a new one.
3. Existing servers: Admin > Servers > server > Startup > select the new image, then restart.

Renamed variables (re-enter custom values after updating the egg):

| Old | New |
|---|---|
| `HYTALE_PATCHLINE` | `PATCHLINE` |
| `HYTALE_ALLOW_OP` | `ALLOW_OP` |
| `HYTALE_ACCEPT_EARLY_PLUGINS` | `ACCEPT_EARLY_PLUGINS` |
| `HYTALE_DISABLE_UPDATES=1` | `AUTO_UPDATE=0` (inverted) |

First boot on the new image prints an OAuth device code in the console; approve it once. The
refresh token is reused for ~30 days. Existing layouts (`Server/HytaleServer.jar` + root
`Assets.zip`) are picked up as-is; the leftover `hytale-downloader/` folder and `version` file can be
deleted.

## Staying current with the fork

```bash
git remote add xytronix https://github.com/Xytronix/yolks.git
git fetch xytronix hytale
git diff HEAD:entrypoint.py xytronix/hytale:games/hytale/entrypoint.py   # review, then merge by hand
```
